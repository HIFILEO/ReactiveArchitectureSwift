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
public class UiModel {
    private(set) var firstTimeLoad:Bool?
    private(set) var failureMsg:String?
    private(set) var pageNumber:Int?
    private(set) var enableScrollListener:Bool
    private var currentList:Array<MovieViewInfo>?
    private(set) var resultList:Array<MovieViewInfo>?
    private(set) var adapterCommandType:AdapterCommandType

    /**
     * Create init state.
     * Note - this can't be a static final becuase you write espresso tests and you'll end up duplicating data.
     * Returns: - new UiModel in init state.
     */
    static func initState() -> UiModel? {
        return UiModel.init(firstTimeLoad: true,
                            failureMsg: nil,
                            pageNumber: 0,
                            enableScrollListener: true,
                            currentList: Array(),
                            resultList: Array(),
                            adapterCommandType: AdapterCommandType.DO_NOTHING)
    }
    
    /**
     * Create success state.
     * Parameters: pageNumber - current page number.
     * Parameters: fullList - latest full list that backs the adapter.
     * Parameters: valuesToAdd - values to add to adapter.
     * Returns: new UiModel
     */
    static func successState(pageNumber:Int, fullList:Array<MovieViewInfo>, valuesToAdd:Array<MovieViewInfo>) -> UiModel {
        return UiModel.init(firstTimeLoad: false,
                            failureMsg: nil,
                            pageNumber: pageNumber,
                            enableScrollListener: true,
                            currentList: fullList,
                            resultList: valuesToAdd,
                            adapterCommandType: AdapterCommandType.ADD_DATA)
    }
    
    /**
     * Create failure state.
     * Parameters: pageNumber - current page number.
     * Parameters: fullList - latest full list that backs the adapter.
     * Parameters: failureMsg - failure message to show
     * Returns: new UiModel
     */
    static func failureState(pageNumber:Int, fullList:Array<MovieViewInfo>, failureMsg:String) -> UiModel {
        return UiModel.init(firstTimeLoad: false,
                            failureMsg: failureMsg,
                            pageNumber: pageNumber,
                            enableScrollListener: false,
                            currentList: fullList,
                            resultList: nil,
                            adapterCommandType: AdapterCommandType.DO_NOTHING)
    }
    
    /**
     * Create in progress state.
     * @param firstTimeLoad - is this first time loading in progress.
     * @param pageNumber - current page number.
     * @param fullList - latest full list that backs the adapter.
     * @return new UiModel
     */
    static func inProgressState(firstTimeLoad:Bool, pageNumber:Int, fullList:Array<MovieViewInfo>) -> UiModel {
        return UiModel.init(firstTimeLoad: firstTimeLoad,
                            failureMsg: nil,
                            pageNumber: pageNumber,
                            enableScrollListener: false,
                            currentList: fullList,
                            resultList: nil,
                            adapterCommandType: firstTimeLoad ? AdapterCommandType.DO_NOTHING : AdapterCommandType.SHOW_IN_PROGRESS)
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

    private init(firstTimeLoad:Bool, failureMsg:String?, pageNumber:Int, enableScrollListener:Bool, currentList:Array<MovieViewInfo>?, resultList:Array<MovieViewInfo>?, adapterCommandType:AdapterCommandType) {
        self.firstTimeLoad = firstTimeLoad
        self.failureMsg = failureMsg
        self.pageNumber = pageNumber
        self.enableScrollListener = enableScrollListener
        self.currentList = currentList
        self.resultList = resultList
        self.adapterCommandType = adapterCommandType
    }
}

