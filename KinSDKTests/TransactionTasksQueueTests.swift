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
    var account1: StellarAccount!
    var account2: StellarAccount!
    var transactionTasksQueueManager: TransactionTasksQueueManager!

    override func setUp() {
        super.setUp()

        KeyStore.removeAll()

        if KeyStore.count() > 0 {
            XCTAssertTrue(false, "Unable to clear existing accounts!")
        }

        account1 = try? KeyStore.newAccount()
        account2 = try? KeyStore.newAccount()

        KinAccountTests.createAccountAndFund(publicAddress: account1.publicKey!, amount: 100)
        KinAccountTests.createAccountAndFund(publicAddress: account2.publicKey!, amount: 100)

        transactionTasksQueueManager = TransactionTasksQueueManager(account: account1)
    }

    override func tearDown() {
        super.tearDown()

        KeyStore.removeAll()
    }

    func createPendingPayment(source: String? = nil, destination: String? = nil) -> PendingPayment {
        let source = source ?? account1.publicKey!
        let destination = destination ?? account2.publicKey!

        return PendingPayment(destinationPublicAddress: destination, sourcePublicAddress: source, amount: 1, metadata: nil)
    }

    func testQueue() {
        let expectation = XCTestExpectation()

        transactionTasksQueueManager.enqueue(pendingPayments: [createPendingPayment()])

        wait(for: [expectation], timeout: 100)
    }
}

