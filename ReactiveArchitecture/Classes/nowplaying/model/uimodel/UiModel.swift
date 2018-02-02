//
//  UiModel.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 12/14/17.
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

 /**
  * The model the UI will bind to.
  * Note - fields in this class should be immutable for "Scan" safety.
  */
class UiModel {
    private(set) var firstTimeLoad: Bool
    private(set) var failureMsg: String?
    private(set) var pageNumber: Int
    private(set) var enableScrollListener: Bool
    private var currentList: Array<MovieViewInfo>?
    private(set) var resultList: Array<MovieViewInfo>?
    private(set) var adapterCommandType: AdapterCommandType

    /**
     * Create init state.
     * Note - this can't be a static final becuase you write espresso tests and you'll end up duplicating data.
     * Returns: - new UiModel in init state.
     */
    static func initState() -> UiModel {
        return UiModel.init(firstTimeLoad: true,
                            failureMsg: nil,
                            pageNumber: 0,
                            enableScrollListener: false,
                            currentList: Array(),
                            resultList: nil,
                            adapterCommandType: AdapterCommandType.doNothing)
    }
    
    /**
     * Create success state.
     * Parameters: pageNumber - current page number.
     * Parameters: fullList - latest full list that backs the adapter.
     * Parameters: valuesToAdd - values to add to adapter.
     * Returns: new UiModel
     */
    static func successState(pageNumber: Int, fullList: Array<MovieViewInfo>, valuesToAdd: Array<MovieViewInfo>) -> UiModel {
        return UiModel.init(firstTimeLoad: false,
                            failureMsg: nil,
                            pageNumber: pageNumber,
                            enableScrollListener: true,
                            currentList: fullList,
                            resultList: valuesToAdd,
                            adapterCommandType: AdapterCommandType.addData)
    }
    
    /**
     * Create failure state.
     * Parameters: pageNumber - current page number.
     * Parameters: fullList - latest full list that backs the adapter.
     * Parameters: failureMsg - failure message to show
     * Returns: new UiModel
     */
    static func failureState(pageNumber: Int, fullList: Array<MovieViewInfo>, failureMsg: String) -> UiModel {
        return UiModel.init(firstTimeLoad: false,
                            failureMsg: failureMsg,
                            pageNumber: pageNumber,
                            enableScrollListener: false,
                            currentList: fullList,
                            resultList: nil,
                            adapterCommandType: AdapterCommandType.doNothing)
    }
    
    /**
     * Create in progress state.
     * @param firstTimeLoad - is this first time loading in progress.
     * @param pageNumber - current page number.
     * @param fullList - latest full list that backs the adapter.
     * @return new UiModel
     */
    static func inProgressState(firstTimeLoad: Bool, pageNumber: Int, fullList: Array<MovieViewInfo>?) -> UiModel {
        return UiModel.init(firstTimeLoad: firstTimeLoad,
                            failureMsg: nil,
                            pageNumber: pageNumber,
                            enableScrollListener: false,
                            currentList: fullList,
                            resultList: nil,
                            adapterCommandType: firstTimeLoad ? AdapterCommandType.doNothing : AdapterCommandType.showInProgress)
    }

    /**
     * Return a shallow copy of the current list.
     * Returns: Shallow copy of list.
     */
    func getCurrentList() -> Array<MovieViewInfo>? {
        //Array containers are struts in swift, a simple copy is a recreation assignment.
        let arrayCopy: Array<MovieViewInfo>? = currentList
        return arrayCopy
    }

    fileprivate init(firstTimeLoad: Bool, failureMsg: String?, pageNumber: Int, enableScrollListener: Bool,
                     currentList: Array<MovieViewInfo>?, resultList: Array<MovieViewInfo>?,
                     adapterCommandType: AdapterCommandType) {
        self.firstTimeLoad = firstTimeLoad
        self.failureMsg = failureMsg
        self.pageNumber = pageNumber
        self.enableScrollListener = enableScrollListener
        self.currentList = currentList
        self.resultList = resultList
        self.adapterCommandType = adapterCommandType
    }
    
    /**
     * Too many state? Too many params in constructors? Call on the builder pattern to Save The Day!.
     */
    public class UiModelBuilder {
        private let uiModel: UiModel?
        
        private var firstTimeLoad: Bool
        private var failureMsg: String?
        private var pageNumber: Int
        private var enableScrollListener: Bool
        private var currentList: Array<MovieViewInfo>?
        private var resultList: Array<MovieViewInfo>?
        private var adapterCommandType: AdapterCommandType
        
        /**
         * Construct Builder using defaults from previous {@link UiModel}.
         * @param uiModel - model for builder to use.
         */
        init(uiModel: UiModel) {
            self.uiModel = uiModel
            
            self.firstTimeLoad = uiModel.firstTimeLoad
            self.failureMsg = uiModel.failureMsg
            self.pageNumber = uiModel.pageNumber
            self.enableScrollListener = uiModel.enableScrollListener
            self.currentList = uiModel.getCurrentList()
            self.resultList = uiModel.resultList
            self.adapterCommandType = uiModel.adapterCommandType
        }
        
        init() {
            self.uiModel = nil
            
            //Note - annyoing but in Swfit you don't get primitive type defaults.
            self.firstTimeLoad = false
            self.pageNumber = 0
            self.enableScrollListener = false
            self.adapterCommandType = AdapterCommandType.doNothing
        }
        
        /**
         * Create the {@link UiModel} using the types in {@link UiModelBuilder}.
         * @return new {@link UiModel}.
         */
        func createUiModel() -> UiModel {
            if currentList == nil {
                if uiModel == nil {
                    currentList = Array<MovieViewInfo>()
                } else {
                    //shallow copy
                    currentList = uiModel?.getCurrentList()
                }
            }
            
            return UiModel.init(
                firstTimeLoad: self.firstTimeLoad,
                failureMsg: self.failureMsg,
                pageNumber: self.pageNumber,
                enableScrollListener: self.enableScrollListener,
                currentList: self.currentList,
                resultList: self.resultList,
                adapterCommandType: self.adapterCommandType)
        }
        
        func setFirstTimeLoad(firstTimeLoad: Bool) -> UiModelBuilder {
            self.firstTimeLoad = firstTimeLoad
            return self
        }
        
        func setFailureMsg(failureMsg: String) -> UiModelBuilder {
            self.failureMsg = failureMsg
            return self
        }
        
        func setPageNumber(pageNumber: Int) -> UiModelBuilder {
            self.pageNumber = pageNumber
            return self
        }

        func setEnableScrollListener(enableScrollListener: Bool) -> UiModelBuilder {
            self.enableScrollListener = enableScrollListener
            return self
        }
        
        func setCurrentList(currentList: Array<MovieViewInfo>) -> UiModelBuilder {
            self.currentList = currentList
            return self
        }
        
        func setResultList(resultList: Array<MovieViewInfo>) -> UiModelBuilder {
            self.resultList = resultList
            return self
        }
        
        func setAdapterCommandType(adapterCommandType: AdapterCommandType) -> UiModelBuilder {
            self.adapterCommandType = adapterCommandType
            return self
        }
    }
}
