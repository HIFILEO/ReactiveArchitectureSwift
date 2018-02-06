//
//  NowPlayingInteractorTest.swift
//  ReactiveArchitectureTests
//
//  Created by leonardis on 1/11/18.
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
@testable import ReactiveArchitecture
import RxSwift
import RxTest
import RxBlocking
import Hamcrest
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack

class NowPlayingInteractorTest: RxSwiftTest {
    var mockServiceController: ServiceController?
    
    let movieInfo: MovieInfo = MovieInfoImpl.init(
        pictureUrl: "www.url.com",
        title: "Dan The Man",
        releaseDate: Date.init(),
        rating: 9)
    let pageNumber: Int = 1
    let totalPAgeNumber: Int = 10
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testScrollAction_pass() {
        //
        //Arrange
        //
        let testableObserver = testScheduler!.createObserver(Result.self)
        
        var movieInfoList: Array<MovieInfo> = Array<MovieInfo>()
        for _ in 1...5 {
            movieInfoList.append(movieInfo)
        }
        let nowPlayingInfo: NowPlayingInfo = NowPlayingInfoImpl.init(movieInfoList: movieInfoList,
                                                                     pageNumber: pageNumber,
                                                                     totalPageNumber: totalPAgeNumber)

        mockServiceController = MockServiceController.init(returnValue: Observable.just(nowPlayingInfo))
        
        let nowPlayingInteractor: NowPlayingInteractor = NowPlayingInteractorImpl.initForTest(
            serviceController: mockServiceController!,
            delayScheduler: testScheduler!)
        
        //
        //Act
        //
        DDLogInfo("scheduler.Clock: " + String.init(testScheduler!.clock))
        nowPlayingInteractor.processAction(actions: Observable.just(ScrollAction.init(pageNumber: pageNumber)))
        .subscribe(testableObserver)
        .disposed(by: self.disboseBag!)
        testScheduler!.advanceTo(4)
        DDLogInfo("scheduler.Clock: " + String.init(testScheduler!.clock))
        testScheduler!.start()
        
        //
        //Arrange
        //
        TestableObserverUtil.assertNoErrors(testObserver: testableObserver)
        TestableObserverUtil.assertValueCount(testObserver: testableObserver, count: 2)
        
        //IN_FLIGHT Test
        let result: Result = testableObserver.events[0].value.element!
        assertThat(result, not(nilValue()))
        assertThat(result, instanceOf(ScrollResult.self))
        
        let scrollResult : ScrollResult = result as! ScrollResult
        assertThat(scrollResult.pageNumber, equalTo(pageNumber))
        assertThat(scrollResult.error, nilValue())
        assertThat(scrollResult.result, nilValue())
        assertThat(scrollResult.getType(), equalTo(ResultType.inFlight) )
        
        //SUCCESS
        let resultSuccess: Result = testableObserver.events[1].value.element!
        assertThat(resultSuccess, not(nilValue()))
        assertThat(resultSuccess, instanceOf(ScrollResult.self))
        
        let scrollResultSuccess: ScrollResult = resultSuccess as! ScrollResult
        assertThat(scrollResultSuccess.pageNumber, equalTo(pageNumber))
        assertThat(scrollResultSuccess.error, nilValue())
        assertThat(scrollResultSuccess.result!.count, greaterThan(0))
        assertThat(scrollResultSuccess.result!, hasCount(5))
        assertThat(scrollResultSuccess.getType(), equalTo(ResultType.success))
    
        //Note - sadly with generics you have problems doing tests without a concrete class to caast to.
        for i in 0...4 {
            let movieInfoImpl: MovieInfoImpl = movieInfo as! MovieInfoImpl
            let movieInfoImplUnderTest: MovieInfoImpl = scrollResultSuccess.result![i] as! MovieInfoImpl
            assertThat(movieInfoImpl, sameInstance(movieInfoImplUnderTest))
        }
    }
    
    func testScrollAction_fail() {
        //
        //Arrange
        //
        let testableObserver = testScheduler!.createObserver(Result.self)
        
        let msg: String = "Error Message";
        let testError: TestError = TestError.RuntimeError(message: msg)
        
        mockServiceController = MockServiceController.init(returnValue: Observable.error(testError))
        
        let nowPlayingInteractor: NowPlayingInteractor = NowPlayingInteractorImpl.initForTest(
            serviceController: mockServiceController!,
            delayScheduler: testScheduler!)
        
        //
        //Act
        //
        nowPlayingInteractor.processAction(actions: Observable.just(ScrollAction.init(pageNumber: pageNumber)))
            .subscribe(testableObserver)
            .disposed(by: self.disboseBag!)
        testScheduler!.advanceTo(4)
        testScheduler!.start()
        
        //
        //Assert
        //
        TestableObserverUtil.assertNoErrors(testObserver: testableObserver)
        TestableObserverUtil.assertValueCount(testObserver: testableObserver, count: 2)
        
        //IN_FLIGHT Test
        let result: Result = testableObserver.events[0].value.element!
        assertThat(result, not(nilValue()))
        assertThat(result, instanceOf(ScrollResult.self))
        
        let scrollResult : ScrollResult = result as! ScrollResult
        assertThat(scrollResult.pageNumber, equalTo(pageNumber))
        assertThat(scrollResult.error, nilValue())
        assertThat(scrollResult.result, nilValue())
        assertThat(scrollResult.getType(), equalTo(ResultType.inFlight) )

        //FAILURE
        let failureResult: Result = testableObserver.events[1].value.element!
        assertThat(failureResult, not(nilValue()))
        assertThat(failureResult, instanceOf(ScrollResult.self))
        
        let scrollResultFailure: ScrollResult = failureResult as! ScrollResult
        assertThat(scrollResultFailure.pageNumber, equalTo(pageNumber))
        assertThat(scrollResultFailure.error, not(nilValue()))
        
        let testErrorUnderTest : TestError = scrollResultFailure.error! as! TestError
        assertThat(testErrorUnderTest.localizedDescription, equalTo(msg))
        assertThat(scrollResultFailure.result, nilValue())
        assertThat(scrollResultFailure.getType(), equalTo(ResultType.failure))
    }
    
    
    /**
     Although there are mocking libraries for Swfit, they don't do a good job since the language prohibits reflection
     Therefore we create our own mocking classes since I don't need to 'verify' or 'spy' for Reactive Architecture
    */
    public class MockServiceController : ServiceController {
        let returnValue : Observable<NowPlayingInfo>
        
        init (returnValue: Observable<NowPlayingInfo>) {
            self.returnValue = returnValue
        }
        
        func getNowPlaying(pageNumber: Int) -> Observable<NowPlayingInfo> {
            return returnValue
        }
    }

}
