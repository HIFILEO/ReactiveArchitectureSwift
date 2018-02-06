//
//  NowPlayingInteractor .swift
//  ReactiveArchitecture
//
//  Created by leonardis on 1/15/18.
//  Copyright © 2018 leonardis. All rights reserved.
//

import Foundation
import RxSwift

protocol NowPlayingInteractor: class {
    func processAction(actions: Observable<Action>) -> Observable<Result>
}
