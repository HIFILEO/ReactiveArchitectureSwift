//
//  Result.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 1/5/18.
//  Copyright © 2018 leonardis. All rights reserved.
//

import Foundation

/**
 * Base class for results from asynchronous actions.
 */
protocol Result: class {
    
    func getType() -> ResultType
    
}

enum ResultType {
    case IN_FLIGHT
    case SUCCESS
    case FAILURE
}
