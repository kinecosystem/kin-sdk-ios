//
// URLKinVersion.swift
// KinSDKTests
//
// Created by Kin Foundation.
// Copyright © 2019 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK

// TODO: rename to URLKinVersionTests
class URLKinVersion: XCTestCase {

    let url = URL(string: "http://kin.org")!

    func hasVersionHeader(in request: URLRequest?) -> Bool {
        return request?.allHTTPHeaderFields?.contains(where: { $0.key == URLSession.versionHeaderField }) ?? false
    }

    func testHasVersionHeaderFromDataTask() {
        let task = URLSession.shared.kinDataTask(with: URLRequest(url: url))
        XCTAssertTrue(hasVersionHeader(in: task.currentRequest))
    }

    func testAbsentVersionHeaderFromDataTask() {
        let task = URLSession.shared.dataTask(with: URLRequest(url: url))
        XCTAssertFalse(hasVersionHeader(in: task.currentRequest))
    }

    func testHasVersionHeaderFromConfiguration() {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = URLSessionConfiguration.kinAdditionalHeaders()

        let task = URLSession(configuration: config).dataTask(with: url)
        XCTAssertTrue(hasVersionHeader(in: task.currentRequest))
    }

    func testAbsentVersionHeaderFromConfiguration() {
        let config = URLSessionConfiguration.default

        let task = URLSession(configuration: config).dataTask(with: url)
        XCTAssertFalse(hasVersionHeader(in: task.currentRequest))
    }

}
