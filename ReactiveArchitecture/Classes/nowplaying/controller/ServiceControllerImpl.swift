//
//  ServiceControllerImpl.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 12/6/17.
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
import RxSwift
import CocoaLumberjack

/**
 * Implementation of {@link ServiceController}.
 */
class ServiceControllerImpl: ServiceController {
    var serviceApi: ServiceApi
    var apiKey: String
    var imageUrlPath: String
    
    /**
     Constructor.
     - Parameters:
         -serviceApi: RxAlamo service
         -apiKey: access key
         -imageUrlPath: url base path for showing images
     */
    init(serviceApi: ServiceApi, apiKey: String, imageUrlPath: String) {
        self.serviceApi = serviceApi
        self.apiKey = apiKey
        self.imageUrlPath = imageUrlPath
    }

    func getNowPlaying(pageNumber: Int) -> Observable<NowPlayingInfo> {
        DDLogInfo("Thread name: " + Thread.current.debugDescription + " Get NowPlaying for Page #" + pageNumber.description)
       
        var mapToSend: Dictionary<String, Int> = [String: Int]()
        mapToSend["page"] = pageNumber
        
        /*
         Notes - Load data from web on scheduler thread. Translate the web response to our
         internal business response on computation thread. Return observable.
         */
        return serviceApi.nowPlaying(apiKey: apiKey, query: mapToSend)
            .flatMap { (serviceResponse: ServiceResponse) -> Observable<NowPlayingInfo> in
                return TranslateNowPlayingSubscriptionFunc.init(imageUrlPath: self.imageUrlPath)
                    .apply(serviceResonse: serviceResponse)
            }
            .do(onError: { (error: Error) in
                DDLogError("Failed to get data from service. " + error.localizedDescription)
                throw error
            })
            //Note - unlike android, there is no io or computation scheduler. Each must be redefined with a specific queue as
            //per GCD.
            //subscribe up - call api using ConcurrentDispatchQueueScheduler scheduler.
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global()))
    }
    
    /**
     * Class to translate external {@link ServiceResponse} to internal data for {@link NowPlayingInfo}.
     */
    //NOTE - NESTED CLASSES IN SWIFT ARE NOT THE SAME AS JAVA. MORE LIKE C++
    /* In Swift, an instance of an inner class is independent of any instance of the outer class.
        It is as if all inner classes in Swift are declared using Java's static.
        If you want the instance of the inner class to have a reference to an instance of the outer class,
        you must make it explicit:
    */
    public class TranslateNowPlayingSubscriptionFunc {
        private let dateFormatter = DateFormatter()
        private let imageUrlPath: String
        
        init(imageUrlPath: String) {
            self.imageUrlPath = imageUrlPath
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }
        
        func apply(serviceResonse: ServiceResponse) -> Observable<NowPlayingInfo> {
            DDLogInfo("Thread name: " + Thread.current.debugDescription + " for class" +
                String(describing: TranslateNowPlayingSubscriptionFunc.self))
            
            var movieInfoList = Array<MovieInfo>()
            
            for i: Int in 0 ... (serviceResonse.results.count - 1) {
                guard let releaseDate = dateFormatter.date(from: serviceResonse.results[i].releaseDate) else {
                    continue
                }
                
                guard let posterPath = serviceResonse.results[i].posterPath else {
                    continue
                }
                
                guard let title = serviceResonse.results[i].title else {
                    continue
                }
                
                guard let rating = serviceResonse.results[i].voteAverage else {
                    continue
                }
                
                let movieInfo: MovieInfo = MovieInfoImpl.init(
                    pictureUrl: imageUrlPath + posterPath,
                    title: title,
                    releaseDate: releaseDate,
                    rating: rating)
                
                movieInfoList.append(movieInfo)
            }
    
            return Observable.just(NowPlayingInfoImpl.init(movieInfoList: movieInfoList,
                                                           pageNumber: serviceResonse.page,
                                                           totalPageNumber: serviceResonse.totalPages))
        }
        
    }
}
