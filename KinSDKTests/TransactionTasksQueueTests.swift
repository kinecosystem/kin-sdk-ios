//
//  TransactionTasksQueueTests.swift
//  KinSDKTests
//
//  Created by Corey Werner on 22/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK

class TransactionTasksQueueTests: XCTestCase {
    var transactionTasksQueueManager: TransactionTasksQueueManager!

    override func setUp() {
        super.setUp()

        // These tests are for the queue and not the operations. No need to create real accounts.
        let account = StellarAccount(storageKey: "")
        transactionTasksQueueManager = TransactionTasksQueueManager(account: account)
        transactionTasksQueueManager.isSuspended = true
    }

    func testEnqueueZeroPendingPayments() {
        transactionTasksQueueManager.enqueue(pendingPayments: [])

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 0)
    }

    func testEnqueueSinglePendingPayment() {
        enqueuePendingPayments(count: 1)

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 1)
        numberOfPendingPaymentsInOperations([1])
    }

    func testEnqueueMaxPendingPayments() {
        enqueuePendingPayments(count: maxPendingPaymentCount)

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 1)
        numberOfPendingPaymentsInOperations([maxPendingPaymentCount])
    }

    func testEnqueueOverMaxPendingPayments() {
        enqueuePendingPayments(count: maxPendingPaymentCount + 1)

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 2)
        numberOfPendingPaymentsInOperations([maxPendingPaymentCount, 1])
    }

    func testEnqueueSinglePendingPaymentWithSingleExistingPendingPayment() {
        enqueuePendingPayments(count: 1)
        enqueuePendingPayments(count: 1)

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 1)
        numberOfPendingPaymentsInOperations([2])
    }

    func testEnqueueSinglePendingPaymentWithUnderMaxExistingPendingPayments() {
        enqueuePendingPayments(count: 1)
        enqueuePendingPayments(count: maxPendingPaymentCount - 1)

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 1)
        numberOfPendingPaymentsInOperations([maxPendingPaymentCount])
    }

    func testEnqueueSinglePendingPaymentWithOverMaxExistingPendingPayments() {
        enqueuePendingPayments(count: 1)
        enqueuePendingPayments(count: maxPendingPaymentCount + 1)

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 2)
        numberOfPendingPaymentsInOperations([maxPendingPaymentCount, 2])
    }

    func testEnqueueMaxPendingPaymentsWithSingleExistingPendingPayment() {
        enqueuePendingPayments(count: maxPendingPaymentCount)
        enqueuePendingPayments(count: 1)

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 2)
        numberOfPendingPaymentsInOperations([maxPendingPaymentCount, 1])
    }
}

// MARK: - Convenience

extension TransactionTasksQueueTests {
    var maxPendingPaymentCount: Int {
        return TransactionTasksQueueManager.maxPendingPaymentCount
    }

    func enqueuePendingPayments(count: Int) {
        let pendingPayments = (0..<count).map { _ in
            PendingPayment(destinationPublicAddress: "", sourcePublicAddress: "", amount: 1)
        }
        transactionTasksQueueManager.enqueue(pendingPayments: pendingPayments)
    }

    func numberOfPendingPaymentsInOperations(_ counts: [Int]) {
        counts.enumerated().forEach { (index: Int, count: Int) in
            let operation = transactionTasksQueueManager.pendingPaymentsOperations[index]
            XCTAssertEqual(operation.pendingPayments.count, count)
        }
    }
}
