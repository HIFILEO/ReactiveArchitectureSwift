//
//  ScrollEventCalculator.swift
//  ReactiveArchitectureTests
//
//  Created by leonardis on 1/13/18.
//  Copyright © 2018 leonardis. All rights reserved.
//

import XCTest
import Hamcrest
@testable import ReactiveArchitecture
import UIKit

/**
 Scroll View Used for testing
 */
class ScrollEventCalculatorTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testIsAtScrollEnd() {
        //
        //Arrange
        //
        let testUIScrollView: TestUIScrollView = TestUIScrollView.init(
            frame: CGRect.init(x: 0, y: 0, width: 1000, height: 1000),
            contentOffset: CGPoint.init(x: 0, y: 990),
            bounds: CGRect.init(x: 0, y: 0, width: 1000, height: 1000),
            contentSize: CGSize.init(width: 50, height: 50),
            contentInset: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))

        //
        //Act
        //
        let scrollEventCalculator = ScrollEventCalculator.init(scrollView: testUIScrollView)
        let value: Bool = scrollEventCalculator.isAtScrollEnd()

        //
        //Assert
        //
        assertThat(value == true)
        }

    
    func testIsAtScrollEnd_false() {
        //
        //Arrange
        //
        let testUIScrollView: TestUIScrollView = TestUIScrollView.init(
            frame: CGRect.init(x: 0, y: 0, width: 1000, height: 1000),
            contentOffset: CGPoint.init(x: 0, y: 100),
            bounds: CGRect.init(x: 0, y: 0, width: 30, height: 30),
            contentSize: CGSize.init(width: 50, height: 50),
            contentInset: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0))
        
        //
        //Act
        //
        let scrollEventCalculator = ScrollEventCalculator.init(scrollView: testUIScrollView)
        let value: Bool = scrollEventCalculator.isAtScrollEnd()
        
        //
        //Assert
        //
        assertThat(value == false)
    }
    
    class TestUIScrollView : UIScrollView {

        init(frame: CGRect, contentOffset: CGPoint, bounds: CGRect, contentSize: CGSize, contentInset: UIEdgeInsets) {
            super.init(frame: frame)
            self.contentOffset = contentOffset
            self.bounds = bounds
            self.contentSize = contentSize
            self.contentInset = contentInset
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            //Not Using
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

