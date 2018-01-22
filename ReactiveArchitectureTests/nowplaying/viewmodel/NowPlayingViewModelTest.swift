//
//  NowPlayingViewModelTest.swift
//  ReactiveArchitectureTests
//
//  Created by leonardis on 1/13/18.
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

import XCTest
import RxSwift
import RxTest
import RxBlocking
import Hamcrest
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack

@testable import ReactiveArchitecture

class NowPlayingViewModelTest: RxSwiftTest {
    private var mockServiceController: MockServiceController!
    
    let movieInfo: MovieInfo = MovieInfoImpl.init(
        pictureUrl: "www.url.com",
        title: "Dan The Man",
        releaseDate: Date.init(),
        rating: 9)
    
    override func setUp() {
        super.setUp()
        self.mockServiceController = MockServiceController.init()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitState() {
        //
        //Arrange
        //
        let testableObserver = testScheduler!.createObserver(UiModel.self)
    
        let observableUndnerTest: Observable<Result> = Observable.empty()
        let mockNowPlayigIteractor: NowPlayingInteractor = MockNowPlayigIteractor.init(observableUnderTest: observableUndnerTest)
        
        let nowPlayingViewModel: TestNowPlayingViewModel =
            TestNowPlayingViewModel.init(serviceController: mockServiceController,
                                         nowPlayingInteractor: mockNowPlayigIteractor,
                                         testScheduler: self.testScheduler!)
        
        //
        //Act
        //
        nowPlayingViewModel.getUiModels()!
            .subscribe(testableObserver)
            .disposed(by: self.disboseBag!)
        testScheduler!.start()
        
        //
        //Assert
        //
        TestableObserverUtil.assertNoErrors(testObserver: testableObserver)
        TestableObserverUtil.assertValueCount(testObserver: testableObserver, count: 1)
        
        let uiModel: UiModel = testableObserver.events[0].value.element!
        assertThat(uiModel, not(nilValue()))
        assertThat(uiModel.firstTimeLoad == true)
        assertThat(uiModel.adapterCommandType, equalTo(AdapterCommandType.doNothing))
        assertThat(uiModel.getCurrentList()!.count, equalTo(0))
        assertThat(uiModel.resultList, nilValue())
        assertThat(uiModel.failureMsg, nilValue())
        assertThat(uiModel.enableScrollListener == false)
        assertThat(uiModel.pageNumber, equalTo(0))
    }
    
    func testInFlightState() {
        //
        //Arrange
        //
        let testableObserver = testScheduler!.createObserver(UiModel.self)
        
        let pageNumber: Int = 1
        let scrollEvent: ScrollEvent = ScrollEvent.init(pageNumber: pageNumber)
        let scrollResult: ScrollResult = ScrollResult.inFlight(pageNumber: pageNumber)
        
        let observableUndnerTest: Observable<Result> = Observable.just(scrollResult)
        let mockNowPlayigIteractor: MockNowPlayigIteractor = MockNowPlayigIteractor.init(observableUnderTest: observableUndnerTest)
        
        let nowPlayingViewModel: TestNowPlayingViewModel =
            TestNowPlayingViewModel.init(serviceController: mockServiceController,
                                         nowPlayingInteractor: mockNowPlayigIteractor,
                                         testScheduler: self.testScheduler!)
        
        //
        //Act
        //
        nowPlayingViewModel.getUiModels()!
            .subscribe(testableObserver)
            .disposed(by: self.disboseBag!)
        nowPlayingViewModel.processUiEvent(uiEvent: scrollEvent)
        testScheduler!.start()
        
        //
        //Assert
        //
        TestableObserverUtil.assertNoErrors(testObserver: testableObserver)
        TestableObserverUtil.assertValueCount(testObserver: testableObserver, count: 2)
        
        //Model Test
        let uiModel: UiModel = testableObserver.events[1].value.element!
        assertThat(uiModel, not(nilValue()))
        assertThat(uiModel.firstTimeLoad == true)
        assertThat(uiModel.adapterCommandType, equalTo(AdapterCommandType.doNothing))
        assertThat(uiModel.getCurrentList()!.count, equalTo(0))
        assertThat(uiModel.resultList, nilValue())
        assertThat(uiModel.failureMsg, nilValue())
        assertThat(uiModel.enableScrollListener == false)
        assertThat(uiModel.pageNumber, equalTo(pageNumber))
        
        //Action translation test
        let action: Action = mockNowPlayigIteractor.actionArgumentCapture
        assertThat(action, not(nilValue()))
        assertThat(action, instanceOf(ScrollAction.self))
        
        let scrollAction: ScrollAction = action as! ScrollAction
        assertThat(scrollAction.getPageNumber(), equalTo(pageNumber))
    }
    
    func testInSuccessState() {
        //
        //Arrange
        //
        let testableObserver = testScheduler!.createObserver(UiModel.self)
        
        let pageNumber: Int = 1
        let scrollEvent: ScrollEvent = ScrollEvent.init(pageNumber: pageNumber)
        let scrollResultInFlight: ScrollResult = ScrollResult.inFlight(pageNumber: pageNumber)
        
        var movieInfoList: Array<MovieInfo> = Array()
        movieInfoList.append(movieInfo)
        let scrollResultSuccess: ScrollResult = ScrollResult.sucess(pageNumber: pageNumber, result: movieInfoList)
        
        
        let observableUndnerTest: Observable<Result> = Observable.just(scrollResultInFlight as Result)
            .concat(Observable.just(scrollResultSuccess  as Result))
        
        let mockNowPlayigIteractor: MockNowPlayigIteractor = MockNowPlayigIteractor.init(observableUnderTest: observableUndnerTest)
        
        let nowPlayingViewModel: TestNowPlayingViewModel =
            TestNowPlayingViewModel.init(serviceController: mockServiceController,
                                         nowPlayingInteractor: mockNowPlayigIteractor,
                                         testScheduler: self.testScheduler!)
        
        //
        //Act
        //
        nowPlayingViewModel.getUiModels()!
            .subscribe(testableObserver)
            .disposed(by: self.disboseBag!)
        nowPlayingViewModel.processUiEvent(uiEvent: scrollEvent)
        testScheduler!.start()
        
        //
        //Assert
        //
        TestableObserverUtil.assertNoErrors(testObserver: testableObserver)
        TestableObserverUtil.assertValueCount(testObserver: testableObserver, count: 3)
        
        //Model Test
        let uiModel: UiModel = testableObserver.events[2].value.element!
        assertThat(uiModel, not(nilValue()))
        assertThat(uiModel.firstTimeLoad == false)
        assertThat(uiModel.adapterCommandType, equalTo(AdapterCommandType.addData))
        assertThat(uiModel.getCurrentList()!.count, greaterThan(0))
        assertThat(uiModel.getCurrentList()!.count, equalTo(1))
        assertThat(uiModel.resultList!.count, greaterThan(0))
        assertThat(uiModel.resultList!.count, equalTo(1))
        assertThat(uiModel.failureMsg, nilValue())
        assertThat(uiModel.enableScrollListener == true)
        assertThat(uiModel.pageNumber, equalTo(pageNumber))
        
        //Test List Data
        let movieViewInfo: MovieViewInfo = uiModel.resultList![0]
        assertThat(movieViewInfo.getPictureUrl(), matchesPattern(movieInfo.getPictureUrl(), options: .caseInsensitive))
        assertThat(movieViewInfo.getTitle(), matchesPattern(movieInfo.getTitle(), options: .caseInsensitive))
        assertThat(movieViewInfo.getRating(), matchesPattern(String(lround(movieInfo.getRating())) + "/10", options: .caseInsensitive))
        assertThat(movieViewInfo.isHighRating() == true)
    }
    
    private class MockServiceController: ServiceController {
        func getNowPlaying(pageNumber: Int) -> Observable<NowPlayingInfo> {
            return Observable.empty()
        }
    }
    
    class MockNowPlayigIteractor : NowPlayingInteractor {
        private var observableUnderTest: Observable<Result>
        public private(set) var actionArgumentCapture: Action!
        
        init(observableUnderTest: Observable<Result>) {
            self.observableUnderTest = observableUnderTest
        }
        
        func processAction(actions: Observable<Action>) -> Observable<Result> {
            return actions
                .flatMap{ action -> Observable<Result> in
                    self.actionArgumentCapture = action
                    return self.observableUnderTest
            }
        }
    }
}
