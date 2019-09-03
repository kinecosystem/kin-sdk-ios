//
//  AsynchronousOperationTests.swift
//  KinSDKTests
//
//  Created by Corey Werner on 02/09/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK

class AsynchronousOperationTests: XCTestCase {
    func testOperationIsAsync() {
        let expectation = XCTestExpectation()

        let operation = AsynchronousTestOperation()

        // Calling start before setting the completion ensures a delay exists on success
        operation.start()

        operation.completionBlock = {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testOperationIsExecuting() {
        let operation = AsynchronousTestOperation()
        operation.start()

        XCTAssertTrue(operation.isExecuting, "Operation should be executing")
        XCTAssertFalse(operation.isFinished, "Operation shouldn't be finished")
        XCTAssertFalse(operation.isReady, "Operation shouldn't be ready")
        XCTAssertFalse(operation.isCancelled, "Operation shouldn't be cancelled")
    }

    func testOperationIsFinished() {
        let expectation = XCTestExpectation()

        let operation = AsynchronousTestOperation()
        operation.completionBlock = {
            XCTAssertFalse(operation.isExecuting, "Operation shouldn't be executing")
            XCTAssertTrue(operation.isFinished, "Operation shouldn be finished")
            XCTAssertFalse(operation.isReady, "Operation shouldn't be ready")
            XCTAssertFalse(operation.isCancelled, "Operation shouldn't be cancelled")

            expectation.fulfill()
        }
        operation.start()

        wait(for: [expectation], timeout: 1)
    }

    func testOperationIsReady() {
        let operation = AsynchronousTestOperation()

        XCTAssertFalse(operation.isExecuting, "Operation shouldn't be executing")
        XCTAssertFalse(operation.isFinished, "Operation shouldn't be finished")
        XCTAssertTrue(operation.isReady, "Operation should be ready")
        XCTAssertFalse(operation.isCancelled, "Operation shouldn't be cancelled")
    }

    func testOperationIsCancelled() {
        let expectation = XCTestExpectation()

        let operation = AsynchronousTestOperation()

        operation.completionBlock = {
            XCTAssertFalse(operation.isExecuting, "Operation shouldn't be executing")
            XCTAssertTrue(operation.isFinished, "Operation shouldn't be finished")
            XCTAssertFalse(operation.isReady, "Operation shouldn't be ready")
            XCTAssertTrue(operation.isCancelled, "Operation should be cancelled")

            expectation.fulfill()
        }

        operation.start()
        operation.cancel()

        wait(for: [expectation], timeout: 1)
    }
}

private class AsynchronousTestOperation: AsynchronousOperation {
    override func workItem() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.markFinished()
        }
    }
}
