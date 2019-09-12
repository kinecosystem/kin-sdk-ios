//
//  AssetTests.swift
//  KinSDKTests
//
//  Created by Corey Werner on 20/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK

class AssetTests: XCTestCase {
    func testKinToQuark() {
        XCTAssertEqual(Kin(5).toQuark(), Quark(500000))
    }

    func testDecimalKinToQuark() {
        XCTAssertEqual(Kin(0.00005).toQuark(), Quark(5))
    }

    func testQuarkToKin() {
        XCTAssertEqual(Quark(500000).toKin(), Kin(5))
    }

    func testQuarkToDecimalKin() {
        XCTAssertEqual(Quark(5).toKin(), Kin(0.00005))
    }
}
