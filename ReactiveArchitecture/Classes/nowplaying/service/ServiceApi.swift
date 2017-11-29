//
//  ServiceApi.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 11/15/17.
//  Copyright © 2017 leonardis. All rights reserved.
//

import Foundation
import RxSwift

protocol ServiceApi {
    func nowPlaying(apiKey: String, query:Dictionary<String, Int>) -> Observable<ServiceResponse>    
}


