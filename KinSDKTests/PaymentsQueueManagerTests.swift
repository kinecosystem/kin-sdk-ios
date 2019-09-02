//
//  PaymentsQueueManagerTests.swift
//  KinSDKTests
//
//  Created by Corey Werner on 15/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK

class PaymentsQueueManagerTests: XCTestCase {
    var paymentsQueueManager: PaymentsQueueManager!
    var pendingPaymentsCallback: (([PendingPayment]) -> ())?
    var didDequeueing = false

    var maxPaymentsTime: TimeInterval {
        return paymentsQueueManager.maxPaymentsTime
    }
    var maxTimeoutTime: TimeInterval {
        return paymentsQueueManager.maxTimeoutTime
    }
    var fractionTime: TimeInterval {
        return maxPaymentsTime * 0.1
    }

    override func setUp() {
        super.setUp()

        paymentsQueueManager = PaymentsQueueManager(maxPaymentsTime: 4, maxTimeoutTime: 10)
        paymentsQueueManager.delegate = self

        pendingPaymentsCallback = nil

        didDequeueing = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func createPendingPayment() -> PendingPayment {
        return PendingPayment(destinationPublicAddress: "", sourcePublicAddress: "", amount: 1, metadata: nil)
    }

    func testMaxPendingPayments() {
        for _ in 0...paymentsQueueManager.maxPendingPayments {
            paymentsQueueManager.enqueue(pendingPayment: createPendingPayment())
        }

        XCTAssertTrue(didDequeueing, "The dequeueing delegate should be called")
        XCTAssertEqual(paymentsQueueManager.operationsCount, 1, "The queue should have only 1 item")
    }

    func testPendingPaymentsFromDelegate() {
        let expectation = XCTestExpectation()

        var pendingPayments: [PendingPayment] = []

        pendingPaymentsCallback = { delegatePendingPayments in
            XCTAssertEqual(delegatePendingPayments, pendingPayments, "The arrays should be the same")
            expectation.fulfill()
        }

        for _ in 0..<paymentsQueueManager.maxPendingPayments {
            let pendingPayment = createPendingPayment()
            pendingPayments.append(pendingPayment)
            paymentsQueueManager.enqueue(pendingPayment: pendingPayment)
        }

        wait(for: [expectation], timeout: maxTimeoutTime)
    }

    func testDelayBetweenPaymentsTimer() {
        let expectation = XCTestExpectation()
        let deadline: DispatchTime = .now() + maxPaymentsTime

        paymentsQueueManager.enqueue(pendingPayment: createPendingPayment())

        DispatchQueue.main.asyncAfter(deadline: deadline - fractionTime) {
            XCTAssertFalse(self.didDequeueing, "The timeout was called too early")
        }

        DispatchQueue.main.asyncAfter(deadline: deadline + fractionTime) {
            XCTAssertTrue(self.didDequeueing, "The timeout wasnt called")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: maxTimeoutTime + fractionTime)
    }

    func testTimeoutTimer() {
        let expectation = XCTestExpectation()
        let iterations = Int(ceil(maxTimeoutTime / maxPaymentsTime))

        for i in 0..<iterations {
            let deadline = (maxPaymentsTime - fractionTime) * TimeInterval(i)

            DispatchQueue.main.asyncAfter(deadline: .now() + deadline) {
                self.paymentsQueueManager.enqueue(pendingPayment: self.createPendingPayment())
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + maxTimeoutTime - fractionTime) {
            XCTAssertFalse(self.didDequeueing, "The timeout was called too early")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + maxTimeoutTime + fractionTime) {
            XCTAssertTrue(self.didDequeueing, "The timeout wasnt called")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: maxTimeoutTime + fractionTime)
    }

    func testInProgess() {
        let expectation = XCTestExpectation()

        XCTAssertFalse(paymentsQueueManager.inProgress, "Should not be in progress")

        paymentsQueueManager.enqueue(pendingPayment: createPendingPayment())

        XCTAssertTrue(paymentsQueueManager.inProgress, "Should be in progress")

        DispatchQueue.main.asyncAfter(deadline: .now() + maxPaymentsTime + fractionTime) {
            XCTAssertFalse(self.paymentsQueueManager.inProgress, "Should not be in progress")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: maxTimeoutTime)
    }
}

extension PaymentsQueueManagerTests: PaymentsQueueManagerDelegate {
    func paymentsQueueManager(_ manager: PaymentsQueueManager, dequeueing pendingPayments: [PendingPayment]) {
        didDequeueing = true
        pendingPaymentsCallback?(pendingPayments)
    }
}
