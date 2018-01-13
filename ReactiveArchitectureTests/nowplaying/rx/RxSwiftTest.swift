//
//  RxSwiftTest.swift
//  ReactiveArchitectureTests
//
//  Created by leonardis on 12/8/17.
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
import RxTest
import RxSwift
import RxBlocking
import Hamcrest
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack

/**
 * Common base class for all RxSwift tests.
 */
public class RxSwiftTest : XCTestCase {
    public var testScheduler:TestScheduler?
    public var disboseBag:DisposeBag?
    
    override public func setUp() {
        super.setUp()
        self.testScheduler = TestScheduler(initialClock: 0)
        self.disboseBag = DisposeBag()
        
        //Setup Logging
        DDLog.add(DDTTYLogger.sharedInstance) // TTY = Xcode console
       // DDLog.add(DDASLLogger.sharedInstance) // ASL = Apple System Logs
        
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
    
    override public func tearDown() {
        super.tearDown()
        self.disboseBag = nil//by assigning to nil, we are forcing ARC to dispose of everything in the sack
    }
    
}
