//
//  NowPlayingViewModelTest.swift
//  ReactiveArchitectureTests
//
//  Created by leonardis on 1/13/18.
//  Copyright © 2018 leonardis. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
import Hamcrest
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack

class NowPlayingViewModelTest: RxSwiftTest {
    private var mockServiceController: MockServiceController!
    
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
        nowPlayingViewModel.getUiModels()
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
        assertThat(uiModel.adapterCommandType, equalTo(AdapterCommandType.DO_NOTHING))
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
        nowPlayingViewModel.getUiModels()
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
        assertThat(uiModel.adapterCommandType, equalTo(AdapterCommandType.DO_NOTHING))
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
