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
    
    private class MockServiceController: ServiceController {
        func getNowPlaying(pageNumber: Int) -> Observable<NowPlayingInfo> {
            return Observable.empty()
        }
    }
    
    class MockNowPlayigIteractor : NowPlayingInteractor {
        private var observableUnderTest: Observable<Result>
        
        init(observableUnderTest: Observable<Result>) {
            self.observableUnderTest = observableUnderTest
        }
        
        func processAction(actions: Observable<Action>) -> Observable<Result> {
            return observableUnderTest
        }
    }
    
    
}
