//
//  QRTests.swift
//  KinBackupRestoreModuleTests
//
//  Created by Corey Werner on 26/03/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBackupRestoreModule

class QRTests: XCTestCase {
    func testQREncodeAndDecode() {
        let string = "A random string to test"

        guard let qrImage = QR.encode(string: string) else {
            XCTAssertTrue(false, "Could not encode QR string")
            return
        }

        guard let qrString = QR.decode(image: qrImage) else {
            XCTAssertTrue(false, "Could not decode QR image")
            return
        }

        XCTAssertTrue(string == qrString, "Strings do not match")
    }

    func testQREmptyDecode() {
        XCTAssertNil(QR.decode(image: UIImage()))
    }
}
