//
//  ServiceControllerImplTest.swift
//  ReactiveArchitectureTests
//
//  Created by leonardis on 12/7/17.
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

import XCTest
@testable import ReactiveArchitecture
import RxTest
import RxSwift
import RxBlocking
import Hamcrest
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack

class ServiceControllerImplTest: RxSwiftTest {
    private let IMAGE_PATH = "www.imagepath.com";
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTranslateNowPlaying() {
        //
        //Arrange
        //
        let testableObserver = testScheduler!.createObserver(NowPlayingInfo.self)
        var json:String?
        do {
            json = try TestResourceFileHelper.getFileContentsAsString(testClass: self,
                                                                      fileName: "now_playing_page_1",
                                                                      fileType: "json")
        } catch {
             XCTFail("Failed to load JSON for unit test.")
        }
        
        guard let serviceResponse = Mapper<ServiceResponse>().map(JSONString: json!) else {
            XCTFail("Failed to convert JSON to ServiceResponse")
            return
        }
        
        let translateNowPlayingSubscriptionFunc = ServiceControllerImpl.TranslateNowPlayingSubscriptionFunc.init(imageUrlPath: IMAGE_PATH)

        //
        //Act
        //
        translateNowPlayingSubscriptionFunc
            .apply(serviceResonse: serviceResponse)
            .subscribe(testableObserver)
            .disposed(by: self.disboseBag!)
        testScheduler!.start()
        
        //
        //Asserrt
        //
        TestableObserverUtil.assertCompleted(testObserver: testableObserver)
        TestableObserverUtil.assertNoErrors(testObserver: testableObserver)
        TestableObserverUtil.assertValueCount(testObserver: testableObserver, count: 1)
        
        let nowPlayingInfo: NowPlayingInfo = testableObserver.events[0].value.element!
        assertThat(nowPlayingInfo, not(nilValue()))
        assertThat(nowPlayingInfo.getPageNumber(), equalTo(1))
        assertThat(nowPlayingInfo.getTotalPageNumber(), equalTo(35))
        assertThat(nowPlayingInfo.getMovies().count, equalTo(20))
        assertThat(nowPlayingInfo.getMovies(), not(nilValue()))
        
        let movieInfo: MovieInfo = nowPlayingInfo.getMovies()[0]
        assertThat(movieInfo.getPictureUrl(), matchesPattern(IMAGE_PATH + "/tnmL0g604PDRJwGJ5fsUSYKFo9.jpg", options: .caseInsensitive))
        assertThat(movieInfo.getRating(), equalTo(7.2))
        // TODO: This fails outside of US timezones
        assertThat(movieInfo.getReleaseDate().description, equalTo("2017-03-15 04:00:00 +0000"))
        assertThat(movieInfo.getTitle(), equalTo("Beauty and the Beast"))
    }
}
