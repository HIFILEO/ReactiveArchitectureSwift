//
//  TestResourceFileHelper.swift
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

/**
 * Helper for reading json data files from src/test/resources.
 */
class TestResourceFileHelper {
    
    /**
    Custom Error
    */
    enum TestError : Error {
        case RuntimeError(String)
    }
    
    /**
     Return the contents of the file with the provided fileName from the test resource directory.
     - parameter testClass: name of test class
     - parameter fileName: Name of file to load
     - parameter fileType: Type of the file to load. Like ".json"
     - returns The contents of the file with the provided fileName from the test resource directory.
     - throws TestError with error message when something goes wrong.
     */
    static func getFileContentsAsString(testClass: XCTestCase, fileName: String, fileType: String) throws -> String {
        let testBundle = Bundle(for: type(of: testClass))
        guard let path = testBundle.path(forResource: fileName, ofType: fileType) else {
            throw TestError.RuntimeError("Failed to get JSON path for unit test")
        }
        
        return try String(contentsOfFile:path, encoding: String.Encoding.utf8)
    }
}
