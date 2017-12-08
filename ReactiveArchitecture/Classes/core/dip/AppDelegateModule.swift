//
//  AppDelegateModule.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 12/5/17.
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

import Dip
import Dip_UI

extension DependencyContainer {
    
    /**
     Configure the Dependency Tree.
     */
    static func configure() -> DependencyContainer {
        return DependencyContainer { container in
            unowned let container = container
            
            //
            //App Singleton
            //
            container.register(.singleton) { ServiceApiImpl(baseUrl: "https://api.themoviedb.org/3/movie") as ServiceApi}
            container.register(.singleton) {
                serviceApi in ServiceControllerImpl(serviceApi: serviceApi,
                                                    apiKey: NSLocalizedString("api_key", comment: ""),
                                                    imageUrlPath: NSLocalizedString("image_url_path", comment: "")
                    ) as ServiceController
            }
            
            //
            // VC Singleton
            //
            container.register {serviceController in NowPlayingViewModel(serviceController: serviceController) as NowPlayingViewModel}
            
            //
            // Inject View Controllers
            //
            container.register(tag: "NowPlayingVC") { NowPlayingViewController() }
                .resolvingProperties { container, controller in
                    controller.nowPlayingViewModel = try container.resolve() as NowPlayingViewModel
            }
            
            DependencyContainer.uiContainers = [container]
        }
    }
}

extension NowPlayingViewController: StoryboardInstantiatable { }


