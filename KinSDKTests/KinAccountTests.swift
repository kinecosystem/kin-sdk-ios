//
//  KinAccountTests.swift
//  KinTestHostTests
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK
import KinUtil

class KinAccountTests: XCTestCase {
    var kinClient: KinClient!
    let passphrase = UUID().uuidString

    var account0: KinAccount!
    var account1: KinAccount!
    var issuer: StellarAccount?

    let requestTimeout: TimeInterval = 30

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        kinClient = KinClientTests.createKinClient()

        account0 = KinAccountTests.createAccount(kinClient: kinClient)
        account1 = KinAccountTests.createAccount(kinClient: kinClient)
    }

    override func tearDown() {
        super.tearDown()

        kinClient.deleteKeystore()
    }

    // MARK: - Extra Data

    func test_extra_data() {
        account0.extra = Data([1, 2, 3])

        XCTAssertEqual(Data([1, 2, 3]), account0.extra)
    }

    // MARK: - Balance

    func test_balance_sync() {
        do {
            var balance = try getBalance(account0)

            if balance == 0 {
                balance = try waitForNonZeroBalance(account: account0)
            }

            XCTAssertNotEqual(balance, 0)
        }
        catch {
            self.fail(on: error)
        }
    }

    func test_balance_async() {
        do {
            let expectation = XCTestExpectation()

            var balanceChecked: Kin? = nil

            _ = try waitForNonZeroBalance(account: account0)

            account0.balance { balance, _ in
                balanceChecked = balance
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: requestTimeout)

            XCTAssertNotEqual(balanceChecked, 0)
        }
        catch {
            self.fail(on: error)
        }
    }

    func test_balance_promise() {
        do {
            let expectation = XCTestExpectation()

            var balanceChecked: Kin? = nil

            _ = try waitForNonZeroBalance(account: account0)

            account0.balance()
                .then { balance in
                    balanceChecked = balance
                }
                .finally {
                    expectation.fulfill()
            }

            wait(for: [expectation], timeout: requestTimeout)

            XCTAssertNotEqual(balanceChecked, 0)
        }
        catch {
            self.fail(on: error)
        }
    }

    // MARK: - Build Transaction

    func test_build_transaction_of_zero_kin() {
        let expectation = XCTestExpectation()

        account0.generateTransaction(to: account1.publicAddress, kin: 0, memo: nil, fee: 0) { (envelope, error) in
            if let _ = envelope {
                XCTAssertTrue(false, "Envelope should be nil")
            }

            guard let error = error else {
                XCTAssertTrue(false, "Error should not be nil")
                return
            }

            guard let kinError = error as? KinError, case KinError.invalidAmount = kinError else {
                XCTAssertTrue(false, "Received unexpected error: \(error.localizedDescription)")
                return
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: requestTimeout)
    }

    // MARK: - Send Transaction

    func test_send_transaction_with_nil_memo() {
        do {
            let expectation = XCTestExpectation()

            let (sendAmount, startBalance0, startBalance1) = try prepareCompareBalance()

            generateTransaction(kin: sendAmount, memo: nil, fee: 0) { envelope in
                do {
                    let txId = try self.sendTransaction(envelope)

                    XCTAssertNotNil(txId, "The transaction ID should not be nil")

                    self.compareBalance(sendAmount: sendAmount, startBalance0: startBalance0, startBalance1: startBalance1, completion: {
                        expectation.fulfill()
                    })
                }
                catch {
                    self.fail(on: error)
                }
            }

            wait(for: [expectation], timeout: requestTimeout * 2)
        }
        catch {
            self.fail(on: error)
        }
    }

    func test_send_transaction_with_memo() {
        do {
            let expectation = XCTestExpectation()

            let (sendAmount, startBalance0, startBalance1) = try prepareCompareBalance()

            generateTransaction(kin: sendAmount, memo: "memo", fee: 0) { envelope in
                do {
                    let txId = try self.sendTransaction(envelope)

                    XCTAssertNotNil(txId, "The transaction ID should not be nil")

                    self.compareBalance(sendAmount: sendAmount, startBalance0: startBalance0, startBalance1: startBalance1, completion: {
                        expectation.fulfill()
                    })
                }
                catch {
                    self.fail(on: error)
                }
            }

            wait(for: [expectation], timeout: requestTimeout * 2)
        }
        catch {
            self.fail(on: error)
        }
    }

    func test_send_transaction_with_empty_memo() {
        do {
            let expectation = XCTestExpectation()

            let (sendAmount, startBalance0, startBalance1) = try prepareCompareBalance()

            generateTransaction(kin: sendAmount, memo: "", fee: 0) { envelope in
                do {
                    let txId = try self.sendTransaction(envelope)

                    XCTAssertNotNil(txId, "The transaction ID should not be nil")

                    self.compareBalance(sendAmount: sendAmount, startBalance0: startBalance0, startBalance1: startBalance1, completion: {
                        expectation.fulfill()
                    })
                }
                catch {
                    self.fail(on: error)
                }
            }

            wait(for: [expectation], timeout: requestTimeout * 2)
        }
        catch {
            self.fail(on: error)
        }
    }

    func test_send_transaction_with_insufficient_funds() {
        do {
            let expectation = XCTestExpectation()

            let balance = try getBalance(account0)
            let amount = balance * Kin(AssetUnitDivisor) + 1

            generateTransaction(kin: amount, memo: nil, fee: 0) { envelope in
                do {
                    _ = try self.sendTransaction(envelope)

                    XCTAssertTrue(false, "Tried to send kin with insufficient funds, but didn't get an error")
                }
                catch {
                    if case KinError.insufficientFunds = error {
                        expectation.fulfill()
                    }
                    else {
                        XCTAssertTrue(false, "Tried to send kin, and got error, but not .insufficientFunds: \(error)")
                    }
                }
            }

            wait(for: [expectation], timeout: requestTimeout)
        }
        catch {
            self.fail(on: error)
        }
    }

    // MARK: - Transaction

//    func testSendTransaction() {
//        do {
//            let expectation = XCTestExpectation()
//
//            let transactionParams = try SendTransactionParams.createSendPaymentParams(publicAddress: account1.publicAddress, amount: 10, fee: 0)
//
//            print("||| start")
//            account0.sendTransaction(transactionParams, interceptor: self) { result in
//                print("||| result")
//                switch result {
//                case .success(let transactionId):
//                    XCTAssertNotNil(transactionId, "Expected a transaction id when completing.")
//
//                case .failure(let error):
//                    self.fail(on: error)
//                }
//            }
//
//            wait(for: [expectation], timeout: requestTimeout)
//        }
//        catch {
//            self.fail(on: error)
//        }
//    }

    // MARK: - Deleting Account

    func test_balance_after_delete() {
        do {
            guard let account = kinClient.accounts[0] else {
                XCTAssert(false, "Failed to get an account")
                return
            }

            try kinClient.deleteAccount(at: 0)
            _ = try getBalance(account)

            XCTAssert(false, "An exception should have been thrown.")
        }
        catch {
            guard let kinError = error as? KinError, case KinError.accountDeleted = kinError else {
                XCTAssertTrue(false, "Received unexpected error: \(error.localizedDescription)")
                return
            }
        }
    }

    func test_transaction_after_delete() {
        do {
            let expectation = XCTestExpectation()

            guard let account = kinClient.accounts[0] else {
                XCTAssert(false, "Failed to get an account")
                return
            }

            try kinClient.deleteAccount(at: 0)

            account.generateTransaction(to: "", kin: 1, memo: nil, fee: 0) { (envelope, error) in
                guard let error = error else {
                    XCTAssertTrue(false, "Error should not be nil")
                    return
                }

                guard let kinError = error as? KinError, case KinError.accountDeleted = kinError else {
                    XCTAssertTrue(false, "Received unexpected error: \(error)")
                    return
                }

                expectation.fulfill()
            }

            wait(for: [expectation], timeout: requestTimeout)
        }
        catch {
            self.fail(on: error)
        }
    }

    // MARK: - Export

    func test_export() {
        do {
            let data = try account0.export(passphrase: passphrase)

            XCTAssertNotNil(data, "Unable to retrieve keyStore account: \(String(describing: account0))")
        }
        catch {
            self.fail(on: error)
        }
    }
}

extension KinAccountTests {
    func getBalance(_ account: KinAccount) throws -> Kin {
        if let balance: Decimal = try serialize(account.balance) {
            return balance
        }

        throw KinError.unknown
    }

    func generateTransaction(kin: Kin, memo: String?, fee: Quark, completion: @escaping (Transaction.Envelope) -> Void) {
        account0.generateTransaction(to: account1.publicAddress, kin: kin, memo: memo, fee: fee) { (paymentTransaction, error) in
            DispatchQueue.main.async {
                self.fail(on: error)

                XCTAssertNotNil(paymentTransaction, "The payment transaction should not be nil")

                guard let paymentTransaction = paymentTransaction else {
                    return
                }

                completion(paymentTransaction.envelope())
            }
        }
    }

    func sendTransaction(_ envelope: Transaction.Envelope) throws -> TransactionId {
        let txClosure = { (txComp: @escaping SendTransactionCompletion) in
            self.account0.sendTransaction(envelope, completion: txComp)
        }

        if let txHash = try serialize(txClosure) {
            return txHash
        }

        throw KinError.unknown
    }

    func waitForNonZeroBalance(account: KinAccount) throws -> Kin {
        var balance = try getBalance(account)

        let predicate = NSPredicate(block: { _, _ in
            do {
                balance = try self.getBalance(account)
            }
            catch {
                self.fail(on: error)
            }

            return balance > 0
        })

        let exp = expectation(for: predicate, evaluatedWith: balance)

        wait(for: [exp], timeout: requestTimeout)

        return balance
    }

    func prepareCompareBalance() throws -> (sendAmount: Decimal, startBalance0: Decimal, startBalance1: Decimal) {
        let sendAmount: Decimal = 5
        var startBalance0 = try getBalance(account0)
        var startBalance1 = try getBalance(account1)

        if startBalance0 == 0 {
            startBalance0 = try waitForNonZeroBalance(account: account0)
        }

        if startBalance1 == 0 {
            startBalance1 = try waitForNonZeroBalance(account: account1)
        }

        return (sendAmount, startBalance0, startBalance1)
    }

    func compareBalance(sendAmount: Decimal, startBalance0: Decimal, startBalance1: Decimal, completion: @escaping () -> ()) {
        do {
            let balance0 = try self.getBalance(self.account0)
            let balance1 = try self.getBalance(self.account1)

            kinClient.minFee().then { quark in
                let fee = (Kin(quark) / Kin(AssetUnitDivisor))

                XCTAssertEqual(balance0, startBalance0 - sendAmount - fee)
                XCTAssertEqual(balance1, startBalance1 + sendAmount)

                completion()
            }
        }
        catch {
            self.fail(on: error)
        }
    }

    func fail(on error: Error?) {
        if let error = error {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
}

extension KinAccountTests: TransactionInterceptor {
    func interceptTransactionSending(process: TransactionProcess) throws -> TransactionId {
        return ""
    }
}

// MARK: - Reusable

extension KinAccountTests {
    static func createAccount(kinClient: KinClient, amount: Kin = 100) -> KinAccount {
        guard let account = try? kinClient.addAccount() else {
            XCTAssertTrue(false, "Unable to create account")
            fatalError()
        }

        KinAccountTests.createAccountAndFund(publicAddress: account.publicAddress, amount: amount)

        return account
    }

    static func createAccountAndFund(publicAddress: String, amount: Kin) {
        let group = DispatchGroup()
        group.enter()

        let url = URL(string: "\(IntegEnvironment.friendbotUrl)?addr=\(publicAddress)&amount=\(amount)")!

        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data,
                let jsonOpt = try? JSONSerialization.jsonObject(with: data, options: []),
                let _ = jsonOpt as? [String: Any]
                else {
                    print("Unable to parse json for createAccount().")

                    group.leave()
                    return
            }

            group.leave()
        }).resume()

        group.wait()
    }
}
