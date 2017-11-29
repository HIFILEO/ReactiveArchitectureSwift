//
//  ServiceApiImpl.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 11/16/17.
//  Copyright © 2017 leonardis. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire
import AlamofireObjectMapper
import ObjectMapper

class ServiceApiImpl: ServiceApi {
    private var baseUrl: String
    
    /**
     Constructor.
     - parameters:
     - baseUrl: Base url for requests from service.
     */
    init(baseUrl: String) {
        self.baseUrl = baseUrl;
    }
    
    func nowPlaying(apiKey: String, query: Dictionary<String, Int>) -> Observable<ServiceResponse> {
        //setup base url
        var urlComps = URLComponents(string: baseUrl)!
        
        //create query items
        var queryItemArray = Array<URLQueryItem>()
        queryItemArray.append(URLQueryItem(name: "api_key", value: apiKey))
        
        for (key, element) in query {
            queryItemArray.append(URLQueryItem(name: key, value: String(element)))
        }
        
        //add query items to url
        urlComps.queryItems = queryItemArray
        
        //create string url
        let url = urlComps.url!
        
        return RxAlamofire.json(.get, url)
            .map{json -> ServiceResponse in
                guard let serviceResponse = Mapper<ServiceResponse>().map(JSONObject: json) else {
                    throw APIError(code: "422", message: "ObjectMapper can't mapping")
                }
                
                return serviceResponse
        }
        
    }
}
