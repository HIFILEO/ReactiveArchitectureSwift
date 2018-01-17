//
//  ViewController.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 11/13/17.
//  Copyright 2017 LEO LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute,
//  sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or
//  substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import RxSwift
import RxCocoa
import CocoaLumberjack
import Toast_Swift

class NowPlayingViewController: UIViewController {
    private var nowPlayingTableViewController: NowPlayingTableViewController?
    private var tableView: UITableView?
    private let compositeDisposable = CompositeDisposable()
    private var scrollDisposable: Disposable?
    private var pageNumber: Int?
    
    //
    //UI Variables
    //
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    
    //
    //Injected Variables
    //
    var nowPlayingViewModel: NowPlayingViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bind()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //Note - I'm manually unbinding when there is no visible screen. Need to use CompositeDisposable
        //https://stackoverflow.com/questions/38969328/manually-disposing-a-disposebag-in-rxswift
        compositeDisposable.dispose()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if (segueName?.caseInsensitiveCompare("EmbedSegueContainer") == ComparisonResult.orderedSame) {
            nowPlayingTableViewController = (segue.destination as! NowPlayingTableViewController)
            tableView = nowPlayingTableViewController!.tableView
            nowPlayingTableViewController!.tableView.isHidden = true
        }
     }
    
    // MARK: - Private Methods
    
    /**
     * Bind to all data in {@link NowPlayingViewModel}.
     */
    private func bind() {
        //
        //Bind to UiModel
        //
       _ = compositeDisposable.insert(nowPlayingViewModel!.getUiModels()
            .subscribe(onNext: { uiModel in
                self.processUiModel(uiModel: uiModel)
            }, onError: {(error) in
                let errorMsg: String = "rrors from Model Unsupported:" + error.localizedDescription
                
                //Note - you can't throw another error in swift. You have to 'terminate' app. Meh
                DDLogError(errorMsg)
                fatalError(errorMsg)
            })
        )
    }
   
    /**
     * Bind to scroll events.
     */
    private func bindToScrollEvent() -> Void {
        //
        //Guard
        //
        if (scrollDisposable != nil) {
            return;
        }
        
        //
        //Bind
        //
        scrollDisposable = self.tableView!.rx.didScroll
            .flatMap{ scrollView -> Observable<ScrollEvent> in
                let scrollEventCalculator:ScrollEventCalculator = ScrollEventCalculator.init(scrollView: self.tableView!)

                //Only handle 'is at end' of list scroll events
                if (scrollEventCalculator.isAtScrollEnd()) {
                    let scrollEvent: ScrollEvent = ScrollEvent.init(pageNumber: self.pageNumber! + 1)

                    return Observable.just(scrollEvent)
                } else {
                    return Observable.empty()
                }
            }
            //Filter any multiple events before 250MS
            .throttle(0.250, scheduler: MainScheduler.instance)
            .subscribe(onNext: { scrollEvent in
                self.nowPlayingViewModel?.processUiEvent(uiEvent: scrollEvent)
            }, onError: {(error) in
                let errorMsg: String = "Errors in scroll event unsupported. Crash app:" + error.localizedDescription
                
                //Note - you can't throw another error in swift. You have to 'terminate' app. Meh
                DDLogError(errorMsg)
                fatalError(errorMsg)
            })
        
        //Note - ignore the returned result. I don't need to keep track of keys
        _ = compositeDisposable.insert(scrollDisposable!)
    }
    
    /**
     * Unbind from scroll events.
     */
    private func unbindFromScrollEvent() -> Void {
        if (scrollDisposable != nil) {
            scrollDisposable?.dispose()
        }
        scrollDisposable = nil
    }
    
    /**
     * Bind to {@link UiModel}.
     * Parameter: uiModel - the {@link UiModel} from {@link NowPlayingViewModel} that backs the UI.
     */
    private func processUiModel(uiModel: UiModel) -> Void {
        /*
         Note - Keep the logic here as SIMPLE as possible.
         */
        DDLogInfo("Thread name: " + Thread.current.debugDescription + "  Update UI based on UiModel")
        
        //
        //Update progressBar
        //
        if (!uiModel.firstTimeLoad) {
            activityIndicator.stopAnimating()
        }
        
        //
        //Update page number
        //
        pageNumber = uiModel.pageNumber
        
        //
        //Update adapter
        //
        if (self.nowPlayingTableViewController!.tableView.isHidden) {
            
            //Process last adapter command
            if (uiModel.adapterCommandType == AdapterCommandType.ADD_DATA) {
                nowPlayingTableViewController!.addAll(listToAdd: uiModel.resultList!)
            } else if (uiModel.adapterCommandType == AdapterCommandType.SHOW_IN_PROGRESS) {
                nowPlayingTableViewController?.add(itemToAdd: nil)
            }
            
            //make table visible
            self.nowPlayingTableViewController!.tableView.isHidden = false
            
            //Trigger first load
            let scrollEvent: ScrollEvent = ScrollEvent.init(pageNumber: self.pageNumber! + 1)
            nowPlayingViewModel?.processUiEvent(uiEvent: scrollEvent)
        } else {
            if (uiModel.adapterCommandType == AdapterCommandType.ADD_DATA) {
                DDLogInfo("Thread name: " + Thread.current.debugDescription + "  Add adapter data on UiModel")
                //Remove Spinner
                if (nowPlayingTableViewController!.getItemCount() > 0) {
                    let positionToRemove: Int = nowPlayingTableViewController!.getItemCount() - 1
                    let objectToRemove: MovieViewInfo = nowPlayingTableViewController!.getItem(position: positionToRemove)!
                    nowPlayingTableViewController?.remove(objectToRemove:objectToRemove)
                }
                
                //Add Data
                nowPlayingTableViewController?.addAll(listToAdd: uiModel.resultList!)
            } else if (uiModel.adapterCommandType == AdapterCommandType.SHOW_IN_PROGRESS) {
                //Add ProgressViewInfoImpl to table. ProgressViewInfoImpl shows spinner in table logic.
                nowPlayingTableViewController?.add(itemToAdd: ProgressViewInfoImpl())
                
                let indexPath = IndexPath.init(row: nowPlayingTableViewController!.getItemCount() - 1, section: 0)
                self.tableView!.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        
        //
        //Error Messages
        //
        if (uiModel.failureMsg != nil && !uiModel.failureMsg!.isEmpty) {
            self.view.makeToast(NSLocalizedString("error_msg", comment: ""))
        }
        
        //
        //Scroll Listener (iOS has to be done last so we don't trigger continuous loads)
        //
        if (uiModel.enableScrollListener) {
            bindToScrollEvent()
        } else {
            unbindFromScrollEvent()
        }
    }
}


