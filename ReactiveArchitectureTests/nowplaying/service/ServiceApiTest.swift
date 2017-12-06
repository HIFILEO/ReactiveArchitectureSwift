//
//  ServiceApiTest.swift
//  ReactiveArchitectureTests
//
//  Created by leonardis on 12/5/17.
//  Copyright © 2017 leonardis. All rights reserved.
//

import XCTest
@testable import ReactiveArchitecture
import RxTest
import RxSwift
import RxBlocking
import Hamcrest

class ServiceApiTest: XCTestCase {
    let API_TOKEN:String = "6efc30f1fdcbe7425ab08503f07e2762"
    var serviceApi:ServiceApi?

    override func setUp() {
        super.setUp()
        self.serviceApi = ServiceApiImpl(baseUrl: "https://api.themoviedb.org/3/movie")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNowPlaying() {
        //
        //Arrange
        //
        var mapToSend:Dictionary<String, Int> = [String: Int]()
        mapToSend["page"] = 1
        
        //
        //Act
        //
        let materializedSequenceResult = self.serviceApi?.nowPlaying(apiKey: API_TOKEN, query: mapToSend).toBlocking().materialize()
        
        //
        //Assert
        //
        var serviceResponse:ServiceResponse?
        
        //Assert comnplete, no errors,&  1 value
        switch materializedSequenceResult {
        case .completed(let elements)?:
            XCTAssertEqual(elements.count, 1)
            serviceResponse = elements[0]
        case .failed(let elements, let error)?:
            XCTFail("Expected result to complete with no errors. Error: " + error.localizedDescription + ". Element Count:" + elements.count.description)
            break
        case .none: break
            //no-op
        }
        
        //Note - only way to access the elements is by switch or getter. There is no getter on the blocker class. Fun right?
        assertThat(serviceResponse, not(nilValue()))
        assertThat((serviceResponse?.page)!, equalTo(1))
        assertThat((serviceResponse?.results)!, not(nilValue()))
        assertThat((serviceResponse?.dates)!, not(nilValue()))
        assertThat((serviceResponse?.total_pages)!, greaterThan(0))
        assertThat((serviceResponse?.total_results)!, greaterThan(0))
    }
}
