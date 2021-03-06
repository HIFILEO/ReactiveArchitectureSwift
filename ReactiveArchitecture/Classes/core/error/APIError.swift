//
//  APIError.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 11/29/17.
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
//
//  Copied from
//  https://github.com/soracom/soracom-sdk-swift/blob/master/Sources/APIError.swift

import Foundation

public struct APIError: Error {
    
    /// The error code. In most cases, this is an error code returned by the API server. However, if the error code begins with
    //"CLI" then it is a client-side error, e.g. something that prevented even getting a response from the server
    //(such as, 'network not available').
    
    let code: String
    
    
    /// The error messsage describing what went wrong.
    
    let message: String
    
    
    /// A non-nil value indicates a client-side error (some error condition that happens on the client side, as opposed to being
    //returned from the API server, e.g. 'network not available'.
    
    let underlyingError: NSError?
    
    
    /// Init an error the normal way, for an error condition returned by the API server.
    
    init(code: String?, message: String?) {
        self.code = code ?? "UNK0001" // copy what Go SDK does
        self.message = message ?? "unknown error"
        // FIXME: Mason 2016-03-06: the Go SDK has one more field, messageArgs, which is used to compose the actual message
        //string, but I haven't yet had time to make that work. (See: api_error.go)
        
        self.underlyingError = nil
    }
    
    
    /// Init an error for a local client-side error. Usually this would be the NSError reported by NSURLSession, e.g. network
    //connection not available.
    
    init(underlyingError: NSError) {
        self.underlyingError = underlyingError
        
        // FIXME: Someday we should have more intelligent error codes and messages based on what the underlying error is.
        
        self.code    = "CLI0666"
        self.message = "A client side error occurred: \(underlyingError)"
    }
    
}
