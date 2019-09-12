//
// AppIdTests.swift
// KinSDK
//
// Created by Kin Foundation.
// Copyright © 2018 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK

class AppIdTests: XCTestCase {
    func test_app_id_not_valid() {
        XCTAssertThrowsError(try AppId(""))
        XCTAssertThrowsError(try AppId("a"))
        XCTAssertThrowsError(try AppId("aa"))
        XCTAssertThrowsError(try AppId("aa "))
        XCTAssertThrowsError(try AppId("aa_"))
        XCTAssertThrowsError(try AppId("aaa "))
        XCTAssertThrowsError(try AppId("aaa_"))
        XCTAssertThrowsError(try AppId("aaaaa"))
    }
    
    func test_app_id_valid() {
        XCTAssertNoThrow(try AppId("aaa"))
        XCTAssertNoThrow(try AppId("aaA"))
        XCTAssertNoThrow(try AppId("aa1"))
        XCTAssertNoThrow(try AppId("aaaa"))
        XCTAssertNoThrow(try AppId("aaaA"))
        XCTAssertNoThrow(try AppId("aaa1"))
    }
}

// MARK: - Reusable

extension AppIdTests {
    static func createAppId() -> AppId {
        guard let appId = try? AppId("test") else {
            XCTAssertTrue(false, "Unable to create app id")
            fatalError()
        }

        return appId
    }
}
