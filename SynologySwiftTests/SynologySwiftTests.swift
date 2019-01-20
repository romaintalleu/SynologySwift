//
//  SynologySwiftTests.swift
//  SynologySwiftTests
//
//  Created by Thomas le Gravier on 19/01/2019.
//  Copyright © 2019 Thomas Le Gravier. All rights reserved.
//

import XCTest
@testable import SynologySwift


class SynologySwiftTests: XCTestCase {

    func testWrongQuickConnectID() {
        
        let delayExpectation = expectation(description: "Waiting SynologySwiftURLResolver")
        
        SynologySwiftURLResolver.resolve(quickConnectId: "unknown-quickConnect-id") { (result) in
            switch result {
            case .success(_): XCTAssertTrue(false)
            case .failure(let error):
                switch error {
                case .other(let errorInfo): XCTAssertTrue(errorInfo == "[Alias not found]")
                case .requestError(_):      XCTAssertTrue(false)
                }
            }
            delayExpectation.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }

}
