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

class ServiceApiTest: XCTestCase {
    let API_TOKEN:String = "6efc30f1fdcbe7425ab08503f07e2762"
    var serviceApi:ServiceApi?
    var disposeBag = DisposeBag()
    var testScheduler:TestScheduler?

    override func setUp() {
        super.setUp()
        self.serviceApi = ServiceApiImpl(baseUrl: "https://api.themoviedb.org/3/movie")
        self.testScheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
