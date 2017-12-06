//
//  AppDelegateModule.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 12/5/17.
//  Copyright © 2017 leonardis. All rights reserved.
//

import Dip
import Dip_UI

extension DependencyContainer {
    
    static func configure() -> DependencyContainer {
        return DependencyContainer { container in
            unowned let container = container
            
            // Register some factory. ServiceImp here implements protocol Service
            container.register { ServiceApiImpl(baseUrl: "https://api.themoviedb.org/3/movie") as ServiceApi}
            
            container.register(tag: "NowPlayingVC") { NowPlayingViewController() }
                .resolvingProperties { container, controller in
                    controller.serviceApi = try container.resolve() as ServiceApi
            }
            
            DependencyContainer.uiContainers = [container]
        }
    }
}

extension NowPlayingViewController: StoryboardInstantiatable { }


