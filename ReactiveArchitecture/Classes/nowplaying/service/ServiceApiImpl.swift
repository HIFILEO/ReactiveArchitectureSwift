//
//  ServiceApiImpl.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 11/16/17.
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
import RxSwift
import RxAlamofire
import AlamofireObjectMapper
import ObjectMapper

/**
 Service Protocal IMPL  for IMDB.
 */
class ServiceApiImpl: ServiceApi {
    private let nowPlayingUrl = "/now_playing"
    private var baseUrl: String
    private var fullUrl: String
    
    /**
     Constructor.
     -Parameter baseUrl: Base url for requests from service.
     */
    init(baseUrl: String) {
        self.baseUrl = baseUrl
        self.fullUrl = baseUrl + nowPlayingUrl
    }
    
    /**
    Load "Now Playing" movies.
     
     -Parameter apiKey: API Key for accessing IMDB
     -Parameter query: Map of optional data to send.
     
     -Returns: Observble<ServiceResponse>
     */
    func nowPlaying(apiKey: String, query: Dictionary<String, Int>) -> Observable<ServiceResponse> {
        //setup base url        
        guard var urlComps = URLComponents(string: fullUrl) else {
            return Observable.error(AppError.runtimeError("URLComponents returned nil"))
        }
        
        //create query items
        var queryItemArray = Array<URLQueryItem>()
        queryItemArray.append(URLQueryItem(name: "api_key", value: apiKey))
        
        for (key, element) in query {
            queryItemArray.append(URLQueryItem(name: key, value: String(element)))
        }
        
        //add query items to url
        urlComps.queryItems = queryItemArray
        
        //create string url
        if let url = urlComps.url {
            return RxAlamofire.json(.get, url)
                .map {json -> ServiceResponse in
                    guard let serviceResponse = Mapper<ServiceResponse>().map(JSONObject: json) else {
                        throw APIError(code: "422", message: "ObjectMapper can't mapping")
                    }
                    
                    return serviceResponse
            }
        } else {
           return Observable.error(AppError.runtimeError("urlComps returned nil"))
        }
    }
}
