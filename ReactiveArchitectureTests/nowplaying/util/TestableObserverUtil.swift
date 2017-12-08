//
//  TestableObserverUtil.swift
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
import Foundation
import RxTest
import RxSwift
import RxBlocking
import Hamcrest

/**
 Utility class to enhance TestableObserver which can't be extended. Fun :(
 
 There are so many nice test abilitys in RxJava that RxSwift is missing. I felt compelled to
 add my won since I use a few all the time.
 */
class TestableObserverUtil<T> {
    
    /**
     * Assert that the {@link: TestableOvserver} has completed.
     * - parameter testObserver: TestableObserver<T>
    */
    static func assertCompleted(testObserver:TestableObserver<T>) {
        var hasCompleted = false
        for recordedEvent:Recorded<Event<T>> in testObserver.events {
            if recordedEvent.value.isCompleted {
                hasCompleted = true
                break
            }
        }
        
        assertThat(hasCompleted == true)
    }
    
    /**
     * Assert that the {@link: TestableOvserver} has no errors.
     * - parameter testObserver: TestableObserver<T>
     */
    static func assertNoErrors(testObserver: TestableObserver<T>) {
        var hasError = false
        for recordedEvent:Recorded<Event<T>> in testObserver.events {
            if recordedEvent.value.error != nil {
                hasError = true
                break
            }
        }
        
        assertThat(hasError == false)
    }
    
    /**
     * Assert that the {@link: TestableOvserver} has a specific count of values.
     * - parameter testObserver: TestableObserver<T>
     * - parameter count: value count to test against
     */
    static func assertValueCount(testObserver: TestableObserver<T>, count: Int) {
        var valueCount = 0
        for recordedEvent:Recorded<Event<T>> in testObserver.events {
            switch recordedEvent.value {
            case .next:
                valueCount += 1
                break
            case .error:
                break
            case .completed:
                break
            }
        }
        
        assertThat(valueCount == count)
    }
}
