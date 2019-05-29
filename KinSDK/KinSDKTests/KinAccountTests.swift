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

    let endpoint = "https://horizon-testnet.kininfrastructure.com"
//    let endpoint = "http://horizon-testnet-one-wallet.kininfrastructure.com"
    let sNetwork: Network = .testNet

    lazy var kNetwork: Network = .testNet

    override func setUp() {
        super.setUp()
        
        guard let appId = try? AppId("test") else {
            XCTAssertTrue(false, "Unable to create app id")
            return
        }
            
        kinClient = KinClient(with: URL(string: endpoint)!, network: kNetwork, appId: appId)

        KeyStore.removeAll()

        if KeyStore.count() > 0 {
            XCTAssertTrue(false, "Unable to clear existing accounts!")
        }

        guard let account0 = try? kinClient.addAccount(), let account1 = try? kinClient.addAccount() else {
            XCTAssertTrue(false, "Unable to create account(s)!")
            return
        }

        self.account0 = account0
        self.account1 = account1

        createAccountAndFund(kinAccount: account0, amount: 100)
        createAccountAndFund(kinAccount: account1, amount: 100)
    }

    override func tearDown() {
        super.tearDown()

        kinClient.deleteKeystore()
    }

    func sendTransaction(_ envelope: TransactionEnvelope, from account: KinAccount) throws -> TransactionId {
        let txClosure = { (txComp: @escaping SendTransactionCompletion) in
            account.sendTransaction(envelope, completion: txComp)
        }

        if let txHash = try serialize(txClosure) {
            return txHash
        }

        throw KinError.unknown
    }

    func getBalance(_ account: KinAccount) throws -> Kin {
        if let balance: Decimal = try serialize(account.balance) {
            return balance
        }

        throw KinError.unknown
    }

    private func createAccountAndFund(kinAccount : KinAccount, amount : Kin) {
        let group = DispatchGroup()
        group.enter()

        let url = URL(string: "http://friendbot-testnet.kininfrastructure.com?addr=\(kinAccount.publicAddress)&amount\(amount)")!
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard
                let data = data,
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

    func wait_for_non_zero_balance(account: KinAccount) throws -> Kin {
        var balance: Decimal = try getBalance(account)

        let exp = expectation(for: NSPredicate(block: { _, _ in
            do {
                balance = try self.getBalance(account)
            }
            catch {
                XCTAssertTrue(false, "Something went wrong: \(error)")
            }

            return balance > 0
        }), evaluatedWith: balance, handler: nil)

        self.wait(for: [exp], timeout: 120)

        return balance
    }

    func test_extra_data() {
        let a1 = kinClient.accounts[0]
        a1?.extra = Data([1, 2, 3])

        let a2 = kinClient.accounts[0]

        XCTAssertEqual(Data([1, 2, 3]), a2?.extra)
    }

    func test_balance_sync() {
        do {
            var balance: Decimal? = try getBalance(account0)

            if balance == 0 {
                balance = try wait_for_non_zero_balance(account: account0)
            }

            XCTAssertNotEqual(balance, 0)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_balance_async() {
        var balanceChecked: Kin? = nil
        let expectation = self.expectation(description: "wait for callback")

        do {
            _ = try wait_for_non_zero_balance(account: account0)

            account0.balance { balance, _ in
                balanceChecked = balance
                expectation.fulfill()
            }

            self.waitForExpectations(timeout: 25.0)

            XCTAssertNotEqual(balanceChecked, 0)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_balance_promise() {
        var balanceChecked: Kin? = nil
        let expectation = self.expectation(description: "wait for callback")

        do {
            _ = try wait_for_non_zero_balance(account: account0)

            account0.balance()
                .then{ balance in
                    balanceChecked = balance
                }
                .finally({
                    expectation.fulfill()
                })

            self.waitForExpectations(timeout: 25.0)

            XCTAssertNotEqual(balanceChecked, 0)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_send_transaction_with_nil_memo() {
        let sendAmount: Decimal = 5

        do {
            var startBalance0: Decimal = try getBalance(account0)
            var startBalance1: Decimal = try getBalance(account1)

            if startBalance0 == 0 {
                startBalance0 = try wait_for_non_zero_balance(account: account0)
            }

            if startBalance1 == 0 {
                startBalance1 = try wait_for_non_zero_balance(account: account1)
            }

            account0.buildTransaction(to: account1.publicAddress, kin: sendAmount, memo: nil, fee: 0) { (envelope, error) in
                let txId = try! self.sendTransaction(envelope!, from: self.account0)

                XCTAssertNotNil(txId)

                let balance0: Decimal = try! self.getBalance(self.account0)
                let balance1: Decimal = try! self.getBalance(self.account1)

                XCTAssertEqual(balance0, startBalance0 - sendAmount)
                XCTAssertEqual(balance1, startBalance1 + sendAmount)
            }
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_send_transaction_with_memo() {
        let sendAmount: Decimal = 5

        do {
            var startBalance0: Decimal = try getBalance(account0)
            var startBalance1: Decimal = try getBalance(account1)

            if startBalance0 == 0 {
                startBalance0 = try wait_for_non_zero_balance(account: account0)
            }

            if startBalance1 == 0 {
                startBalance1 = try wait_for_non_zero_balance(account: account1)
            }

            account0.buildTransaction(to: account1.publicAddress, kin: sendAmount, memo: "memo", fee: 0) { (envelope, error) in
                let txId = try! self.sendTransaction(envelope!, from: self.account0)

                XCTAssertNotNil(txId)

                let balance0: Decimal = try! self.getBalance(self.account0)
                let balance1: Decimal = try! self.getBalance(self.account1)

                XCTAssertEqual(balance0, startBalance0 - sendAmount)
                XCTAssertEqual(balance1, startBalance1 + sendAmount)
            }
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_send_transaction_with_empty_memo() {
        let sendAmount: Decimal = 5

        do {
            var startBalance0: Decimal = try getBalance(account0)
            var startBalance1: Decimal = try getBalance(account1)

            if startBalance0 == 0 {
                startBalance0 = try wait_for_non_zero_balance(account: account0)
            }

            if startBalance1 == 0 {
                startBalance1 = try wait_for_non_zero_balance(account: account1)
            }

            account0.buildTransaction(to: account1.publicAddress, kin: sendAmount, memo: "", fee: 0) { (envelope, error) in
                let txId = try! self.sendTransaction(envelope!, from: self.account0)

                XCTAssertNotNil(txId)

                let balance0: Decimal = try! self.getBalance(self.account0)
                let balance1: Decimal = try! self.getBalance(self.account1)

                XCTAssertEqual(balance0, startBalance0 - sendAmount)
                XCTAssertEqual(balance1, startBalance1 + sendAmount)
            }
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_send_transaction_with_insufficient_funds() {
        do {
            let balance: Decimal = try getBalance(account0)
            let amount = balance * Decimal(AssetUnitDivisor) + 1

            account0.buildTransaction(to: account1.publicAddress, kin: amount, memo: nil, fee: 0) { (envelope, error) in
                do {
                    _ = try self.sendTransaction(envelope!, from: self.account0)

                    XCTAssertTrue(false, "Tried to send kin with insufficient funds, but didn't get an error")
                }
                catch {
                    guard case KinError.insufficientFunds = error else {
                        XCTAssertTrue(false,
                                      "Tried to send kin, and got error, but not .insufficientFunds: \(error)")

                        return
                    }
                }
            }
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_generate_transaction_of_zero_kin() {
        account0.buildTransaction(to: account1.publicAddress, kin: 0, memo: nil, fee: 0) { (envelope, error) in
                if let kinError = error as? KinError,
                    case KinError.invalidAmount = kinError {
                } else {
                    XCTAssertTrue(false,
                                  "Received unexpected error: \(error!.localizedDescription)")
                }
            }
    }

    func test_use_after_delete_balance() {
        do {
            let account = kinClient.accounts[0]

            try kinClient.deleteAccount(at: 0)
            _ = try getBalance(account!)

            XCTAssert(false, "An exception should have been thrown.")
        }
        catch {
            if let kinError = error as? KinError,
                case KinError.accountDeleted = kinError {
            } else {
                XCTAssertTrue(false,
                              "Received unexpected error: \(error.localizedDescription)")
            }
        }
    }

    func test_use_after_delete_transaction() {
        do {
            let account = kinClient.accounts[0]!
            
            try kinClient.deleteAccount(at: 0)

            account.buildTransaction(to: "", kin: 1, memo: nil, fee: 0) { (envelope, error) in
                if let kinError = error as? KinError,
                    case KinError.accountDeleted = kinError {
                } else {
                    XCTAssertTrue(false,
                                  "Received unexpected error: \(error!.localizedDescription)")
                }
            }
        }
        catch {
           
        }
    }

    func test_export() {
        do {
            let account = try kinClient.addAccount()
            let data = try account.export(passphrase: passphrase)

            XCTAssertNotNil(data, "Unable to retrieve keyStore account: \(String(describing: account))")
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_aggregated_balance() {
        account0.aggergatedBalance { (kin, error) in
            if let error = error {
                XCTAssertTrue(false, "Something went wrong: \(error)")
            }

            XCTAssertTrue(kin != nil)
        }
    }

    func test_controlled_accounts() {
        account0.controlledAccounts { (controlledAccounts, error) in
            if let error = error {
                XCTAssertTrue(false, "Something went wrong: \(error)")
            }

            XCTAssertTrue(controlledAccounts != nil)
        }
    }
}
