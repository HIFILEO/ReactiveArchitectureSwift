//
//  ServiceApiTest.swift
//  ReactiveArchitectureTests
//
//  Created by leonardis on 11/30/17.
//  Copyright © 2017 leonardis. All rights reserved.
//

import XCTest
@testable import ReactiveArchitecture

class ServiceApiTest: XCTestCase {
    let API_TOKEN:String = "6efc30f1fdcbe7425ab08503f07e2762"
    var serviceApi:ServiceApi?

    override func setUp() {
        super.setUp()
        serviceApi = ServiceApiImpl(baseUrl: API_TOKEN)
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
        
    }
    
    
}
