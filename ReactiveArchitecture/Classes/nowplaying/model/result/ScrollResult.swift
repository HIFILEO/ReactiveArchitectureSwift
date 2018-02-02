//
//  ScrollResult.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 1/9/18.
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

import UIKit

class ScrollResult: Result {
    private var resultType: ResultType
    private(set) var isSuccessful: Bool
    private(set) var isLoading: Bool?
    private(set) var pageNumber: Int
    private(set) var result: Array<MovieInfo>?
    private(set) var error: Error?
    
    public static func inFlight(pageNumber: Int) -> ScrollResult {
        return ScrollResult.init(resultType: ResultType.inFlight,
                                 isSuccessful: false,
                                 isLoading: true,
                                 pageNumber: pageNumber,
                                 result: nil,
                                 error: nil)
    }

    public static func sucess(pageNumber: Int, result: Array<MovieInfo>) -> ScrollResult {
        return ScrollResult.init(resultType: ResultType.success,
                                 isSuccessful: true,
                                 isLoading: false,
                                 pageNumber: pageNumber,
                                 result: result,
                                 error: nil)
    }
    
    public static func failure(pageNumber: Int, error: Error) -> ScrollResult {
        return ScrollResult.init(resultType: ResultType.failure,
                                 isSuccessful: false,
                                 isLoading: false,
                                 pageNumber: pageNumber,
                                 result: nil,
                                 error: error)
    }
    
    func getType() -> ResultType {
        return self.resultType
    }
    
    private init(resultType: ResultType, isSuccessful: Bool, isLoading: Bool, pageNumber: Int,
                 result: Array<MovieInfo>?, error: Error?) {
        self.resultType = resultType
        self.isSuccessful = isSuccessful
        self.isLoading = isLoading
        self.pageNumber = pageNumber
        self.result = result
        self.error = error
    }
}
