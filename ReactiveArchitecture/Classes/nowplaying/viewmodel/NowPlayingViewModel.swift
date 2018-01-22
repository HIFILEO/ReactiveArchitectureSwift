//
//  NowPlayingViewModel.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 12/6/17.
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

import Foundation
import CocoaLumberjack
import RxSwift

/**
 * View interface to be implemented by the forward facing UI.
 */
class NowPlayingViewModel {
    private let initialUiModel: UiModel = UiModel.initState()
    private var uiModelObservable: Observable<UiModel>?
    private let serviceController: ServiceController
    private let publishSubject: PublishSubject<UiEvent> = PublishSubject.init()
    private var nowPlayingInteractor: NowPlayingInteractor?
    private var backgroundScheduler: SchedulerType?
    private var mainScheduler: SchedulerType?
    
    /**
     Constructor.
     -Parameter baseUrl: Base url for requests from service.
     */
    init(serviceController: ServiceController) {
        self.serviceController = serviceController
        self.mainScheduler = self.createMainScheduler()
        self.backgroundScheduler = self.createBackgroundScheduler()
        initialize()
    }
    
    /**
     Process events from the UI.
     parameter uiEvent - 
     */
    func processUiEvent(uiEvent: UiEvent) {
        DDLogInfo("Thread name: " + Thread.current.debugDescription + " Process UiEvent")
        publishSubject.onNext(uiEvent)
    }
    
    /**
     Get the observable holding the {@link UiModel}
     returns: Observable<UiModel>
    */
    func getUiModels() -> Observable<UiModel> {
        return uiModelObservable!
    }
    
    /**
     Initialize the ViewModel. Visible for testing.
     */
    func initialize() {
        nowPlayingInteractor = createNowPlayingInteractor()
        bind()
    }
    
    /**
    * Creates now playing interactor 
    * Visible for testing.
    * Returns: NowPlayingInteractor
    */
    func createNowPlayingInteractor() -> NowPlayingInteractor {
        return NowPlayingInteractorImpl.init(serviceController: self.serviceController)
    }
    
    func createMainScheduler() -> SchedulerType {
        return MainScheduler.instance
    }
    
    func createBackgroundScheduler() -> SchedulerType {
        return ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
    }
    
    /**
     Bind to {@link PublishRelay}
    */
    func bind() {
        uiModelObservable = publishSubject
            //Note - unlike android, there is no io or computation scheduler. Each must be redefined with a specific queue as per GCD.
            .observeOn(backgroundScheduler!)
            .map { $0 as? ScrollEvent }
            .ignoreNil()
            //Translate UiEvents into Actions
            .flatMap {uiEvent -> Observable<Action> in
                DDLogInfo("Thread name: " + Thread.current.debugDescription + " Translate UiEvents into Actions")
                let scrollAction: ScrollAction = ScrollAction.init(pageNumber: uiEvent.pageNumber)
                return Observable.just(scrollAction)
            }
            //Asynchronous Actions To Interactor (Syntax: https://github.com/ReactiveX/RxSwift/issues/876)
            .multicast({ () -> PublishSubject<Action> in
                return PublishSubject<Action>()
            }, selector: { actions -> Observable<Result> in
                return (self.nowPlayingInteractor?.processAction(actions: actions))!
            })
            .map { $0 as? ScrollResult }
            .ignoreNil()
            .scan(initialUiModel) { (uiModel, result) in
                DDLogInfo("Thread name: " + Thread.current.debugDescription + ". Scan Results to UiModel")

                switch result.getType() {
                case ResultType.inFlight:
                    return UiModel.inProgressState(firstTimeLoad: result.pageNumber == 1,
                                                   pageNumber: result.pageNumber,
                                                   fullList: uiModel.getCurrentList())
                case ResultType.success:
                    let listToAdd: Array<MovieViewInfo>  = self.translateResultsForUi(movieInfoList: result.result!)
                    var currentList: Array<MovieViewInfo> = uiModel.getCurrentList()!
                    currentList.append(contentsOf: listToAdd)
                    
                    return UiModel.successState(pageNumber: result.pageNumber,
                                                fullList: currentList,
                                                valuesToAdd: listToAdd)
                    
                case ResultType.failure:
                    DDLogError(result.error!.localizedDescription)
                    return UiModel.failureState(
                        pageNumber: result.pageNumber - 1,
                        fullList: uiModel.getCurrentList()!,
                        failureMsg: NSLocalizedString("R.string.error_msg", comment: ""))
                }
            }
            //Note - scan in RxSwift does not emit the original seed like RxJava. Since we are using an autoconnect, it's suffice to
            //start with the initial value. 
            .startWith(initialUiModel)
            //Publish results to main thread.
            .observeOn(mainScheduler!)
            //Save history for late subscribers.
            .replay(1)
            /*
             Refcount vs Autoconnect
             Refcount unsubscribes from source when there are no active subscribers, while autoconnect remains connected. There is no
             autoconnect in RxSwift so I created my own.
             */
            //http://akarnokd.blogspot.com/2015/10/operator-internals-autoconnect.html
            .autoconnect()
    }

    // MARK: - Private Methods
    
    /**
     * Translate internal business logic to presenter logic.
     * @param movieInfoList - business list.
     * @return - translated list ready for UI
     */
    private func translateResultsForUi(movieInfoList: Array<MovieInfo>) -> Array<MovieViewInfo> {
        var movieViewInfoList = Array<MovieViewInfo>()
        for movieInfo: MovieInfo in movieInfoList {
            movieViewInfoList.append(MovieViewInfoImpl.init(movieInfo: movieInfo))
        }
        
        return movieViewInfoList
    }
}
