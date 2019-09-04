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
    // !!!: creating accounts takes about 10 sec per test function. instead reuse the accounts. move this logic to a more central location like the KinAccountTests
    static let account1: StellarAccount = {
        let account = try! KeyStore.newAccount()
        KinAccountTests.createAccountAndFund(publicAddress: account.publicKey!, amount: 99999)
        return account
    }()

    static let account2: StellarAccount = {
        let account = try! KeyStore.newAccount()
        KinAccountTests.createAccountAndFund(publicAddress: account.publicKey!, amount: 99999)
        return account
    }()

    var account1: StellarAccount {
        return TransactionTasksQueueTests.account1
    }

    var account2: StellarAccount {
        return TransactionTasksQueueTests.account2
    }

    var transactionTasksQueueManager: TransactionTasksQueueManager!

    override func setUp() {
        super.setUp()

        transactionTasksQueueManager = TransactionTasksQueueManager(account: account1)
    }

    func createPendingPayment(source: String? = nil, destination: String? = nil) -> PendingPayment {
        // ???: to avoid the time overhead of creating accounts, maybe just pass empty strings
        let source = source ?? account1.publicKey!
        let destination = destination ?? account2.publicKey!

        return PendingPayment(destinationPublicAddress: destination, sourcePublicAddress: source, amount: 1)
    }

    func testEnqueueZeroPendingPayments() {
        transactionTasksQueueManager.enqueue(pendingPayments: [])

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 0)
    }

    func testEnqueueSinglePendingPayment() {
        enqueuePendingPayments(count: 1)

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 1)
    }

    func testEnqueueMaxPendingPayments() {
        enqueuePendingPayments(count: TransactionTasksQueueManager.maxPendingPaymentCount)

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 1)
    }

    func testEnqueueOverMaxPendingPayments() {
        enqueuePendingPayments(count: TransactionTasksQueueManager.maxPendingPaymentCount + 1)

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 2)
    }

    func testEnqueueSinglePendingPaymentWithSingleExistingPendingPayment() {
        transactionTasksQueueManager.isSuspended = true
        enqueuePendingPayments(count: 1)
        enqueuePendingPayments(count: 1)
        transactionTasksQueueManager.isSuspended = false

        // TODO: verify the single operation has 2 pending payments
        XCTAssertEqual(transactionTasksQueueManager.operationCount, 1)
    }

    func testEnqueueSinglePendingPaymentWithUnderMaxExistingPendingPayments() {
        transactionTasksQueueManager.isSuspended = true
        enqueuePendingPayments(count: 1)
        enqueuePendingPayments(count: TransactionTasksQueueManager.maxPendingPaymentCount - 1)
        transactionTasksQueueManager.isSuspended = false

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 1)
    }

    func testEnqueueSinglePendingPaymentWithOverMaxExistingPendingPayments() {
        transactionTasksQueueManager.isSuspended = true
        enqueuePendingPayments(count: 1)
        enqueuePendingPayments(count: TransactionTasksQueueManager.maxPendingPaymentCount + 1)
        transactionTasksQueueManager.isSuspended = false

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 2)
    }

    func testEnqueueMaxPendingPaymentsWithSingleExistingPendingPayment() {
        transactionTasksQueueManager.isSuspended = true
        enqueuePendingPayments(count: TransactionTasksQueueManager.maxPendingPaymentCount)
        enqueuePendingPayments(count: 1)
        transactionTasksQueueManager.isSuspended = false

        XCTAssertEqual(transactionTasksQueueManager.operationCount, 2)
    }
}

// MARK: - Convenience

extension TransactionTasksQueueTests {
    func enqueuePendingPayments(count: Int) {
        let pendingPayments = (0..<count).map { _ in createPendingPayment() }
        transactionTasksQueueManager.enqueue(pendingPayments: pendingPayments)
    }
}
