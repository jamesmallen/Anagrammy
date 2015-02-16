//
//  AnagrammyTests.swift
//  AnagrammyTests
//
//  Created by James Allen on 2/3/15.
//  Copyright (c) 2015 James M Allen. All rights reserved.
//

import UIKit
import XCTest


class AnagrammyTests: XCTestCase {
    let v = ViewController()
    
    private let notificationManager = NotificationManager()
    
    var timer: NSTimer!
    var expectation: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewDidLoad() {
        
        XCTAssertNotNil(v.view, "View did not load")
    }
    
    func testLoadedDictionary() {
        expectation = expectationWithDescription("loaded")
        
        notificationManager.registerObserver(dictionaryLoadedNotificationKey) { notificiation in
            self.expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(20.0) { error in
            XCTAssertNil(error, "Error loading dictionary")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
