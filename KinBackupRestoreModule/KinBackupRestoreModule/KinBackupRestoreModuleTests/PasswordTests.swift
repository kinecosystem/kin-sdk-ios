//
//  PasswordTests.swift
//  KinBackupRestoreModuleTests
//
//  Created by Corey Werner on 26/03/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBackupRestoreModule

class PasswordTests: XCTestCase {
    func testValidPassword() {
        XCTAssertTrue(try Password.matches("aaaaaaA1!"))
    }

    func testInvalidPassword() {
        XCTAssertFalse(try Password.matches(""))
        XCTAssertFalse(try Password.matches("aaaaaaA1"))
        XCTAssertFalse(try Password.matches("aaaaaaA1 "))
        XCTAssertFalse(try Password.matches("aaaaaaA1a"))
        XCTAssertFalse(try Password.matches("aaaaaaAa!"))
        XCTAssertFalse(try Password.matches("aaaaaaa1!"))
        XCTAssertFalse(try Password.matches("aaaaaaa1a"))
        XCTAssertFalse(try Password.matches("aaaaaaAaa"))
        XCTAssertFalse(try Password.matches("aaaaaaaa!"))
        XCTAssertFalse(try Password.matches("aaaaaaaaa"))
        XCTAssertFalse(try Password.matches("AAAAAAAAA"))
        XCTAssertFalse(try Password.matches("111111111"))
        XCTAssertFalse(try Password.matches("!!!!!!!!!"))
    }
}
