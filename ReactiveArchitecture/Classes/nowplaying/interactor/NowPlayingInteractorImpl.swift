//
//  NowPlayingInteractor.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 1/3/18.
//  Copyright 2018 LEO LLC
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
import RxSwift
import CocoaLumberjack

/**
 * Interactor for Now Playing movies. Handles internal business logic interactions.
 */
class NowPlayingInteractorImpl: NowPlayingInteractor {
    fileprivate var delayScheduler: SchedulerType = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
    private let serviceController: ServiceController
    //becuase we init a self in a closure this can't be a let or w/o?
    private var transformActionToResult: ObservableTransformer<ScrollAction, ScrollResult>!

    /**
     Create class for test.
     @param serviceController - Controller to fetch data from.
     @param delayScheduler - test Scheduler
     */
    static func initForTest(serviceController: ServiceController, delayScheduler: SchedulerType) -> NowPlayingInteractor {
        let nowPlayingInteractorForTest = NowPlayingInteractorImpl.init(serviceController: serviceController)
        nowPlayingInteractorForTest.delayScheduler = delayScheduler//MainScheduler.instance
        return nowPlayingInteractorForTest
    }
    
    /**
     * Constructor.
     * @param serviceController - Controller to fetch data from.
     */
    init(serviceController: ServiceController) {
        self.serviceController = serviceController
        
        transformActionToResult = ObservableTransformer<ScrollAction, ScrollResult> { observable in
            observable.flatMap { (scrollAction: ScrollAction) -> Observable<ScrollResult> in                            
                DDLogInfo("Thread name: " + Thread.current.debugDescription + " Load Data, return ScrollResult.")
                
                let pageNumberObservable: Observable<Int> = Observable.just(scrollAction.getPageNumber())
                
                let sedrviceControllerObservable: Observable<Array<MovieInfo>> =
                    self.serviceController.getNowPlaying(pageNumber: scrollAction.getPageNumber())
                        //Delay for 3 seconds to show spinner on screen.
                        .delay(3, scheduler: self.delayScheduler)
                        //translate external to internal business logic (Example if we wanted to save to prefs)
                        .flatMap { (nowPlayingInfo: NowPlayingInfo) -> Observable<Array<MovieInfo>> in
                            DDLogInfo("Thread name: " + Thread.current.description + " translate External Api Data into Business Internal Business Logic Data.")
                            return Observable.just(nowPlayingInfo.getMovies())
                        }
                
                //Combine the two observables into result. We need the page number combined w/ results (in case of error).
                return Observable.zip(
                    pageNumberObservable,
                    sedrviceControllerObservable) { (pageNumber: Int, movieInfos: Array<MovieInfo>) -> ScrollResult in
                        return ScrollResult.sucess(pageNumber: pageNumber, result: movieInfos)
                    }
                    //RxJava - onErrorReturn
                    .catchError { (error: Error) -> Observable<ScrollResult> in
                        Observable.just(ScrollResult.failure(pageNumber: scrollAction.getPageNumber(), error: error))
                    }
                    .startWith(ScrollResult.inFlight(pageNumber: scrollAction.getPageNumber()))
                }
        }
    }
    
    /**
     * Process {@link Action}.
     * @param actions - action to process.
     * @return - {@link Result} of the asynchronous event.
     */
    func processAction(actions: Observable<Action>) -> Observable<Result> {
        return actions
            .map { $0 as? ScrollAction }
            .ignoreNil()
            .flatMap { action -> Observable<ScrollAction> in
                DDLogInfo("Thread name: " + Thread.current.description + " Translate Actions into ScrollActions.")
                return Observable.just(action)
            }
            .compose(self.transformActionToResult)
            .flatMap { (scrollResult: ScrollResult) -> Observable<Result> in
                Observable.just(scrollResult as Result)
            }
    }

}
