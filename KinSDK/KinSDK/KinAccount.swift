//
//  KinAccount.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation
import KinUtil


protocol KinAccountProtocol {
    var publicAddress: String { get }

    /**
     Query the status of the account on the blockchain.

     - Parameter completion: The completion handler function with the `AccountStatus` or an `Error.
     */
    func status(completion: @escaping (AccountStatus?, Error?) -> Void)

    /**
     Retrieve the current Kin balance.

     - Note: The closure is invoked on a background thread.

     - Parameter completion: A closure to be invoked once the request completes.
     */
    func balance(completion: @escaping BalanceCompletion)

    var paymentQueue: PaymentQueue { get }

    func sendTransaction(_ params: SendTransactionParams, interceptor: TransactionInterceptor?, completion: @escaping (Result<TransactionId, Error>) -> Void)

    /**
     Export the account data as a JSON string.  The seed is encrypted.

     - Parameter passphrase: The passphrase with which to encrypt the seed

     - Returns: A JSON representation of the data as a string
     */
    func export(passphrase: String) throws -> String

    /**
     Watch for changes on the account balance.

     - Parameter balance: An optional `Kin` balance that the watcher will be notified of first.

     - Returns: A `BalanceWatch` object that will notify of any balance changes.
     */
    func watchBalance(_ balance: Kin?) throws -> BalanceWatch

    /**
     Watch for changes of account payments.

     - Parameter cursor: An optional `cursor` that specifies the id of the last payment after which the watcher will be notified of the new payments.

     - Returns: A `PaymentWatch` object that will notify of any payment changes.
     */
    func watchPayments(cursor: String?) throws -> PaymentWatch

    /**
     Watch for the creation of an account.

     - Returns: A `Promise` that signals when the account is detected to have the `.created` `AccountStatus`.
     */
    func watchCreation() throws -> Promise<Void>
}


/**
 `KinAccount` represents an account which holds Kin. It allows checking balance and sending Kin to
 other accounts.
 */
public final class KinAccount: KinAccountProtocol {
    fileprivate let stellar: StellarProtocol
    let stellarAccount: StellarAccount
    let appId: AppId
    var deleted = false

    public let publicAddress: String

    init(stellar: StellarProtocol, stellarAccount: StellarAccount, appId: AppId) {
        self.stellar = stellar
        self.stellarAccount = stellarAccount
        self.appId = appId
        self.publicAddress = stellarAccount.publicAddress
    }

    // MARK: Inspecting

    public func status(completion: @escaping (AccountStatus?, Error?) -> Void) {
        balance { balance, error in
            if let error = error {
                if case let KinError.balanceQueryFailed(e) = error, let stellarError = e as? StellarError {
                    switch stellarError {
                    case .missingAccount, .missingBalance:
                        completion(.notCreated, nil)
                    default:
                        completion(nil, error)
                    }
                }
                else {
                    completion(nil, error)
                }

                return
            }

            if balance != nil {
                completion(.created, nil)
            }
            else {
                completion(nil, KinError.internalInconsistency)
            }
        }
    }

    public func status() -> Promise<AccountStatus> {
        return promise(status)
    }

    public func balance(completion: @escaping BalanceCompletion) {
        guard deleted == false else {
            completion(nil, KinError.accountDeleted)

            return
        }

        stellar.balance(publicAddress: publicAddress)
            .then { balance -> Void in
                completion(balance, nil)
            }
            .error { error in
                completion(nil, KinError.balanceQueryFailed(error))
        }
    }

    public func balance() -> Promise<Kin> {
        return promise(balance)
    }

    // MARK: Transactions

    public lazy var paymentQueue: PaymentQueue = {
        return PaymentQueue(stellar: stellar, stellarAccount: stellarAccount)
    }()

    public func sendTransaction(_ params: SendTransactionParams, interceptor: TransactionInterceptor? = nil, completion: @escaping (Result<TransactionId, Error>) -> Void) {
        paymentQueue.enqueueTransactionParams(params, completion: completion)
    }

    public func sendTransaction(_ params: SendTransactionParams, interceptor: TransactionInterceptor? = nil) -> Promise<TransactionId> {
        let promise = Promise<TransactionId>()

        sendTransaction(params, interceptor: interceptor) { result in
            switch result {
            case .failure(let error):
                promise.signal(error)
            case .success(let success):
                promise.signal(success)
            }
        }

        return promise
    }

    // MARK: Backup

    public func export(passphrase: String) throws -> String {
        let ad = KeyStore.exportAccount(account: stellarAccount, passphrase: passphrase)

        guard let jsonString = try String(data: JSONEncoder().encode(ad), encoding: .utf8) else {
            throw KinError.internalInconsistency
        }

        return jsonString
    }

    // MARK: Watching

    func watchBalance(_ balance: Kin?) throws -> BalanceWatch {
        guard deleted == false else {
            throw KinError.accountDeleted
        }

        return BalanceWatch(balance: balance, stellar: stellar, stellarAccount: stellarAccount)
    }

    func watchPayments(cursor: String?) throws -> PaymentWatch {
        guard deleted == false else {
            throw KinError.accountDeleted
        }

        return PaymentWatch(cursor: cursor, stellar: stellar, stellarAccount: stellarAccount)
    }

    func watchCreation() throws -> Promise<Void> {
        guard deleted == false else {
            throw KinError.accountDeleted
        }

        let p = Promise<Void>()
        var linkBag = LinkBag()
        var watch: CreationWatch? = CreationWatch(stellar: stellar, stellarAccount: stellarAccount)

        _ = watch?.emitter.on(next: { _ in
            watch = nil

            linkBag = LinkBag()

            p.signal(())
        }).add(to: linkBag)

        return p
    }

    // MARK:

    // ???: is this needed? deprecate?
    var extra: Data? {
        get {
            guard let extra = try? stellarAccount.extra() else {
                return nil
            }

            return extra
        }
        set {
            try? KeyStore.set(extra: newValue, for: stellarAccount)
        }
    }
}

// MARK: - Deprecated

extension KinAccount {
    /**
     Build a Kin transaction for a specific address.

     The completion block is called after the transaction is posted on the network, which is prior
     to confirmation.

     - Attention: The completion block **is not dispatched on the main thread**.

     - Parameter recipient: The recipient's public address.
     - Parameter kin: The amount of Kin to be sent.
     - Parameter memo: An optional string, up-to 28 bytes in length, included on the transaction record.
     - Parameter fee: The fee in `Quark`s used if the transaction is not whitelisted.
     - Parameter completion: A completion with the `PaymentTransaction` or an `Error`.
     */
    @available(*, deprecated, renamed: "sendTransaction(params:interceptor:completion:)")
    public func generateTransaction(to recipient: String, kin: Kin, memo: String? = nil, fee: Quark = 0, completion: @escaping GenerateTransactionCompletion) {
        guard deleted == false else {
            completion(nil, KinError.accountDeleted)
            return
        }

        guard kin > 0 else {
            completion(nil, KinError.invalidAmount)
            return
        }

        let prefixedMemo = Memo.prependAppIdIfNeeded(appId, to: memo ?? "")

        guard prefixedMemo.utf8.count <= Transaction.MaxMemoLength else {
            completion(nil, StellarError.memoTooLong(prefixedMemo))
            return
        }

        do {
            stellar.transaction(sourceStellarAccount: stellarAccount,
                                destinationPublicAddess: recipient,
                                amount: kin,
                                memo: try Memo(prefixedMemo),
                                fee: fee)
                .then { paymentTransaction -> Void in
                    completion(paymentTransaction, nil)
                }
                .error { error in
                    completion(nil, KinError.transactionCreationFailed(error))
            }
        }
        catch {
            completion(nil, error)
        }
    }

    /**
     Build a Kin transaction for a specific address.

     - Parameter recipient: The recipient's public address.
     - Parameter kin: The amount of Kin to be sent.
     - Parameter memo: An optional string, up-to 28 bytes in length, included on the transaction record.
     - Parameter fee: The fee in `Quark`s used if the transaction is not whitelisted.

     - Returns: A promise which is signalled with the `PaymentTransaction` or an `Error`.
     */
    @available(*, deprecated, renamed: "sendTransaction(params:interceptor:)")
    public func generateTransaction(to recipient: String, kin: Kin, memo: String? = nil, fee: Quark) -> Promise<PaymentTransaction> {
        let txClosure = { (txComp: @escaping GenerateTransactionCompletion) in
            self.generateTransaction(to: recipient, kin: kin, memo: memo, fee: fee, completion: txComp)
        }

        return promise(txClosure)
    }

    /**
     Send a Kin transaction.

     The completion block is called after the transaction is posted on the network, which is prior
     to confirmation.

     - Attention: The completion block **is not dispatched on the main thread**.

     - Parameter envelope: The `Transaction.Envelope` to send.
     - Parameter completion: A completion with the `TransactionId` or an `Error`.
     */
    @available(*, deprecated)
    public func sendTransaction(_ envelope: Transaction.Envelope, completion: @escaping SendTransactionCompletion) {
        guard deleted == false else {
            completion(nil, KinError.accountDeleted)
            return
        }

        stellar.postTransaction(envelope: envelope)
            .then { txHash -> Void in
                completion(txHash, nil)
            }
            .error { error in
                if let error = error as? PaymentError, error == .PAYMENT_UNDERFUNDED {
                    completion(nil, KinError.insufficientFunds)
                    return
                }

                completion(nil, KinError.paymentFailed(error))
        }
    }

    /**
     Send a Kin transaction.

     - Parameter envelope: The `Transaction.Envelope` to send.

     - Returns: A promise which is signalled with the `TransactionId` or an `Error`.
     */
    @available(*, deprecated)
    public func sendTransaction(_ envelope: Transaction.Envelope) -> Promise<TransactionId> {
        let txClosure = { (txComp: @escaping SendTransactionCompletion) in
            self.sendTransaction(envelope, completion: txComp)
        }

        return promise(txClosure)
    }
}
