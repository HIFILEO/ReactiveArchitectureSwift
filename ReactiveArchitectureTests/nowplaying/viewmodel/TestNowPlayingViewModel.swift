//
//  TestNowPlayingViewModel.swift
//  ReactiveArchitectureTests
//
//  Created by leonardis on 1/13/18.
//  Copyright © 2018 leonardis. All rights reserved.
//

import RxSwift

class TestNowPlayingViewModel: NowPlayingViewModel {
    var testScheduler: SchedulerType
    var nowPlayingInteractor: NowPlayingInteractor
    
    init(serviceController: ServiceController, nowPlayingInteractor: NowPlayingInteractor, testScheduler: SchedulerType) {
        self.testScheduler = testScheduler
        self.nowPlayingInteractor = nowPlayingInteractor
        super.init(serviceController: serviceController)
    }

    override func createNowPlayingInteractor() -> NowPlayingInteractor {
        return self.nowPlayingInteractor
    }
    
    override func createMainScheduler() -> SchedulerType {
        return testScheduler
    }
    
    override func createBackgroundScheduler() -> SchedulerType {
        return testScheduler
    }
}
