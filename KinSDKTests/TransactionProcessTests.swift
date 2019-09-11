//
//  TransactionProcessTests.swift
//  KinSDKTests
//
//  Created by Corey Werner on 10/09/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK

class TransactionProcessTests: XCTestCase {

    override func setUp() {
        super.setUp()

    }

    override func tearDown() {
        super.tearDown()

        KinEssentials.shared.deleteKeystore()
    }

    func testSendTransaction() {
        let process = MockTransactionProcess()
        let transaction = process.transaction()

        do {
            let transactionId = try process.sendTransaction(transaction)
        }
        catch {

        }
    }

    func testSendWhitelistTransaction() {

    }
}

class MockTransactionProcess: TransactionProcess {
    func transaction() -> BaseTransaction {
        var result: Result<BaseTransaction, Error> = .failure(KinError.internalInconsistency)

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        Stellar.transaction(source: KinEssentials.shared.account0.stellarAccount,
                            destination: KinEssentials.shared.account1.publicAddress,
                            amount: 10,
                            memo: .MEMO_NONE,
                            fee: 0)
            .then { baseTransaction in
                result = .success(baseTransaction)
                dispatchGroup.leave()
            }
            .error { error in
                result = .failure(error)
                dispatchGroup.leave()
        }

        dispatchGroup.wait()

        switch result {
        case .success(let transaction):
            return transaction
        case .failure(let error):
            XCTAssertTrue(false, "Transaction should exist from mock implementation. \(error)")
            fatalError()
        }
    }
}
