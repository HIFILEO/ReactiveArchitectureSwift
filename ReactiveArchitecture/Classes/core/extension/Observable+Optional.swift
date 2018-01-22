//
//  Observable+Optional.swift
//  ReactiveArchitecture
//
//  Created by Maximilian Clarke on 22/1/18.
//  Copyright © 2018 leonardis. All rights reserved.
//

import Foundation
import RxSwift

// From https://gist.github.com/alskipp/e71f014c8f8a9aa12b8d8f8053b67d72

protocol OptionalType {
    associatedtype Wrapped
    
    var optional: Wrapped? { get }
}

extension Optional: OptionalType {
    public var optional: Wrapped? { return self }
}

extension Observable where Element: OptionalType {
    func ignoreNil() -> Observable<Element.Wrapped> {
        return flatMap { value -> Observable<Element.Wrapped> in
            value.optional.map { .just($0) } ?? .empty()
        }
    }
}
