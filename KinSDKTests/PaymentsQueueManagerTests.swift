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

    }

    func testTimeoutTimer() {
        
    }
}

extension PaymentsQueueManagerTests: PaymentsQueueManagerDelegate {
    func paymentsQueueManager(_ manager: PaymentsQueueManager, dequeueing pendingPayments: [PendingPayment]) {
        didDequeueing = true
//        print("inside dequeueing")
    }
}
