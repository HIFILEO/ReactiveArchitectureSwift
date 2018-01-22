//
//  ArrayExtension.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 12/19/17.
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

extension Array {
    
    /**
     Remove an {@linke:Element} from the array.
     
     Note - make sure the Element works with AnyObject otherwise the remove won't work. Ever.
     https://stackoverflow.com/questions/47897028/how-to-remove-a-protocol-from-array/47915561#47915561
     
     Parameters: element - element to remove
     Returns: true when deleted, false otherwise.
     */
    mutating func removeObject(element: Element) {
        guard let index = index(where: { $0 as AnyObject === element as AnyObject }) else { return }
        remove(at: index)
    }
    
    func indexOf(element: Element) -> Int {
        guard let index = index(where: { $0 as AnyObject === element as AnyObject }) else { return -1 }
        return index
    }
}
