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
    var didDequeueing = false
    var maxDelayBetweenPayments: TimeInterval {
        return paymentsQueueManager.maxDelayBetweenPayments
    }
    var maxTimeout: TimeInterval {
        return paymentsQueueManager.maxTimeout
    }

    override func setUp() {
        super.setUp()

        paymentsQueueManager = PaymentsQueueManager()
        paymentsQueueManager.delegate = self

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

    func testDelayBetweenPaymentsTimer() {
        let expectation = XCTestExpectation()
        let deadline: DispatchTime = .now() + maxDelayBetweenPayments

        paymentsQueueManager.enqueue(pendingPayment: createPendingPayment())

        DispatchQueue.main.asyncAfter(deadline: deadline - 0.1) {
            XCTAssertFalse(self.didDequeueing, "The timeout was called too early")
        }

        DispatchQueue.main.asyncAfter(deadline: deadline + 0.1) {
            XCTAssertTrue(self.didDequeueing, "The timeout wasnt called")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: maxTimeout + 1)
    }

    func testTimeoutTimer() {
        let expectation = XCTestExpectation()
        let iterations = Int(ceil(maxTimeout / maxDelayBetweenPayments))

        for i in 0..<iterations {
            let deadline = maxDelayBetweenPayments * TimeInterval(i) - 0.1

            DispatchQueue.main.asyncAfter(deadline: .now() + deadline) {
                self.paymentsQueueManager.enqueue(pendingPayment: self.createPendingPayment())
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + maxTimeout - 0.1) {
            XCTAssertFalse(self.didDequeueing, "The timeout was called too early")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + maxTimeout + 0.1) {
            XCTAssertTrue(self.didDequeueing, "The timeout wasnt called")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: maxTimeout + 1)
    }

    func testInProgess() {
        let expectation = XCTestExpectation()

        XCTAssertFalse(paymentsQueueManager.inProgress, "Should not be in progress")

        paymentsQueueManager.enqueue(pendingPayment: createPendingPayment())

        XCTAssertTrue(paymentsQueueManager.inProgress, "Should be in progress")

        DispatchQueue.main.asyncAfter(deadline: .now() + maxDelayBetweenPayments + 0.1) {
            XCTAssertFalse(self.paymentsQueueManager.inProgress, "Should not be in progress")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: maxTimeout)
    }
}

extension PaymentsQueueManagerTests: PaymentsQueueManagerDelegate {
    func paymentsQueueManager(_ manager: PaymentsQueueManager, dequeueing pendingPayments: [PendingPayment]) {
        didDequeueing = true
    }
}
