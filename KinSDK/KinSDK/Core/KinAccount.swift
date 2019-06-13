//
//  KinAccount.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation
import KinUtil

/**
 `KinAccount` represents an account which holds Kin. It allows checking balance and sending Kin to
 other accounts.
 */
public final class KinAccount {
    internal let stellarAccount: StellarAccount
    fileprivate let node: Stellar.Node
    fileprivate let appId: AppId

    var deleted = false

    /**
     The public address of this account. If the user wants to receive KIN by sending his address
     manually to someone, or if you want to display the public address, use this property.
     */
    public var publicAddress: String {
        return stellarAccount.publicKey!
    }

    public var extra: Data? {
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

    init(stellarAccount: StellarAccount, node: Stellar.Node, appId: AppId) {
        self.stellarAccount = stellarAccount
        self.node = node
        self.appId = appId
    }

    /**
     Export the account data as a JSON string.  The seed is encrypted.

     - Parameter passphrase: The passphrase with which to encrypt the seed

     - Returns: A JSON representation of the data as a string
     */
    public func export(passphrase: String) throws -> String {
        let ad = KeyStore.exportAccount(account: stellarAccount,
                                        passphrase: "",
                                        newPassphrase: passphrase)

        guard let jsonString = try String(data: JSONEncoder().encode(ad), encoding: .utf8) else {
            throw KinError.internalInconsistency
        }

        return jsonString
    }

    /**
     Query the status of the account on the blockchain.

     - Parameter completion: The completion handler function with the `AccountStatus` or an `Error.
     */
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

    /**
     Query the status of the account on the blockchain using promises.

     - Returns: A promise which will signal the `AccountStatus` value.
     */
    public func status() -> Promise<AccountStatus> {
        return promise(status)
    }

    /**
     Build a Kin transaction for a specific address.

     The completion block is called after the transaction is posted on the network, which is prior
     to confirmation.

     - Attention: The completion block **is not dispatched on the main thread**.

     - Parameter recipient: The recipient's public address.
     - Parameter kin: The amount of Kin to be sent.
     - Parameter memo: An optional string, up-to 28 bytes in length, included on the transaction record.
     - Parameter fee: The fee in `Quark`s used if the transaction is not whitelisted.
     - Parameter completion: A completion with the `TransactionEnvelope` or an `Error`.
     */
    public func buildTransaction(from fromAddress: String? = nil, to recipient: String, kin: Kin, memo: String? = nil, fee: Quark = 0, completion: @escaping GenerateTransactionCompletion) {
        guard deleted == false else {
            completion(nil, KinError.accountDeleted)
            return
        }

        let kinInt = ((kin * Decimal(AssetUnitDivisor)) as NSDecimalNumber).int64Value

        guard kinInt > 0 else {
            completion(nil, KinError.invalidAmount)
            return
        }

        let prefixedMemo = Memo.prependAppIdIfNeeded(appId, to: memo ?? "")

        guard prefixedMemo.utf8.count <= Transaction.MaxMemoLength else {
            completion(nil, StellarError.memoTooLong(prefixedMemo))
            return
        }

        stellarAccount.sign = { message in
            return try self.stellarAccount.sign(message: message, passphrase: "")
        }

        struct AuthorizedAccount: Account {
            let publicKey: String?
            let sign: (([UInt8]) throws -> [UInt8])? = nil
        }

        do {
            Stellar.transaction(signer: stellarAccount,
                                from: fromAddress != nil ? AuthorizedAccount(publicKey: fromAddress) : nil,
                                destination: recipient,
                                amount: kinInt,
                                memo: try Memo(prefixedMemo),
                                node: node,
                                fee: fee)
                .then { transactionEnvelope -> Void in
                    self.stellarAccount.sign = nil
                    completion(transactionEnvelope, nil)
                }
                .error { error in
                    self.stellarAccount.sign = nil
                    completion(nil, KinError.transactionCreationFailed(error))
            }
        }
        catch {
            self.stellarAccount.sign = nil
            completion(nil, error)
        }
    }

    /**
     Build a Kin transaction for a specific address.

     - Parameter recipient: The recipient's public address.
     - Parameter kin: The amount of Kin to be sent.
     - Parameter memo: An optional string, up-to 28 bytes in length, included on the transaction record.
     - Parameter fee: The fee in `Quark`s used if the transaction is not whitelisted.

     - Returns: A promise which is signalled with the `TransactionEnvelope` or an `Error`.
     */
    public func buildTransaction(from fromAddress: String? = nil, to recipient: String, kin: Kin, memo: String? = nil, fee: Quark) -> Promise<TransactionEnvelope> {
        let txClosure = { (txComp: @escaping GenerateTransactionCompletion) in
            self.buildTransaction(from: fromAddress, to: recipient, kin: kin, memo: memo, fee: fee, completion: txComp)
        }

        return promise(txClosure)
    }

    /**
     Send a Kin transaction.

     The completion block is called after the transaction is posted on the network, which is prior
     to confirmation.

     - Attention: The completion block **is not dispatched on the main thread**.

     - Parameter transactionEnvelope: The `TransactionEnvelope` to send.
     - Parameter completion: A completion with the `TransactionId` or an `Error`.
     */
    public func sendTransaction(_ transactionEnvelope: TransactionEnvelope, completion: @escaping SendTransactionCompletion) {
        guard deleted == false else {
            completion(nil, KinError.accountDeleted)
            return
        }

        Stellar.postTransaction(envelope: transactionEnvelope, node: node)
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

     - Parameter transactionEnvelope: The `TransactionEnvelope` to send.

     - Returns: A promise which is signalled with the `TransactionId` or an `Error`.
     */
    public func sendTransaction(_ transactionEnvelope: TransactionEnvelope) -> Promise<TransactionId> {
        let txClosure = { (txComp: @escaping SendTransactionCompletion) in
            self.sendTransaction(transactionEnvelope, completion: txComp)
        }

        return promise(txClosure)
    }

    /**
     Retrieve the current Kin balance.

     - Note: The closure is invoked on a background thread.

     - Parameter completion: A closure to be invoked once the request completes.
     */
    public func balance(completion: @escaping BalanceCompletion) {
        guard deleted == false else {
            completion(nil, KinError.accountDeleted)

            return
        }

        Stellar.balance(account: stellarAccount.publicKey!, node: node)
            .then { balance -> Void in
                completion(balance, nil)
            }
            .error { error in
                completion(nil, KinError.balanceQueryFailed(error))
        }
    }

    /**
     Retrieve the current Kin balance.

     - returns: A `Promise` which is signalled with the current balance.
     */
    public func balance() -> Promise<Kin> {
        return promise(balance)
    }

    /**
     Retrieve the aggregated Kin balance.

     The aggregated balance is the combined balance of all linked accounts.

     - Parameter publicAddress: An optional address to check the aggregated balance.
     - Parameter completion: A closure to be invoked once the request completes.
     */
    public func aggregatedBalance(for publicAddress: String? = nil, completion: @escaping BalanceCompletion) {
        guard deleted == false else {
            completion(nil, KinError.accountDeleted)
            return
        }

        Stellar.aggregatedBalance(account: publicAddress ?? stellarAccount.publicKey!, node: node)
            .then { balance -> Void in
                completion(balance, nil)
            }
            .error { error in
                completion(nil, KinError.aggregatedBalanceQueryFailed(error))
        }
    }

    /**
     Retrieve the controlled accounts.

     The controlled accounts are all of the linked accounts.

     - Parameter completion: A closure to be invoked once the request completes.
     */
    public func controlledAccounts(completion: @escaping ([ControlledAccount]?, Error?) -> Void) {
        guard deleted == false else {
            completion(nil, KinError.accountDeleted)
            return
        }

        Stellar.controlledAccounts(account: stellarAccount.publicKey!, node: node)
            .then { controlledAccounts -> Void in
                completion(controlledAccounts, nil)
            }
            .error { error in
                completion(nil, KinError.controlledAccountsQueryFailed(error))
        }
    }

    /**
     Watch for changes on the account balance.

     - Parameter balance: An optional `Kin` balance that the watcher will be notified of first.

     - Returns: A `BalanceWatch` object that will notify of any balance changes.
     */
    public func watchBalance(_ balance: Kin?) throws -> BalanceWatch {
        guard deleted == false else {
            throw KinError.accountDeleted
        }

        return BalanceWatch(node: node, account: stellarAccount.publicKey!, balance: balance)
    }

    /**
     Watch for changes of account payments.

     - Parameter cursor: An optional `cursor` that specifies the id of the last payment after which the watcher will be notified of the new payments.

     - Returns: A `PaymentWatch` object that will notify of any payment changes.
     */
    public func watchPayments(cursor: String?) throws -> PaymentWatch {
        guard deleted == false else {
            throw KinError.accountDeleted
        }

        return PaymentWatch(node: node, account: stellarAccount.publicKey!, cursor: cursor)
    }

    /**
     Watch for the creation of an account.

     - Returns: A `Promise` that signals when the account is detected to have the `.created` `AccountStatus`.
     */
    public func watchCreation() throws -> Promise<Void> {
        guard deleted == false else {
            throw KinError.accountDeleted
        }

        let p = Promise<Void>()

        var linkBag = LinkBag()
        var watch: CreationWatch? = CreationWatch(node: node, account: stellarAccount.publicKey!)

        _ = watch?.emitter.on(next: { _ in
            watch = nil

            linkBag = LinkBag()

            p.signal(())
        }).add(to: linkBag)

        return p
    }

    /**
     Exports this account as a Key Store JSON string, to be backed up by the user.

     - parameter passphrase: The passphrase used to create the associated account.
     - parameter exportPassphrase: A new passphrase, to encrypt the Key Store JSON.

     - throws: If the passphrase is invalid, or if exporting the associated account fails.

     - returns: a prettified JSON string of the `account` exported; `nil` if `account` is `nil`.
     */
    @available(*, unavailable)
    private func exportKeyStore(passphrase: String, exportPassphrase: String) throws -> String? {
        let accountData = KeyStore.exportAccount(account: stellarAccount, passphrase: passphrase, newPassphrase: exportPassphrase)
        
        guard let store = accountData else {
            throw KinError.internalInconsistency
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: store, options: [.prettyPrinted]) else {
            return nil
        }
        
        return String(data: jsonData, encoding: .utf8)
    }

    public func linkAccount(to publicAddress: String, appBundleIdentifier: String) -> Promise<TransactionEnvelope> {
        let signer = Signer(publicAddress: stellarAccount.publicKey!)
        let signingOp = SetOptionsOp(signer: signer)
        let signOpSourceAccountKey = PublicKey.PUBLIC_KEY_TYPE_ED25519(WrappedData32(BCKeyUtils.key(base32: publicAddress)))

        let manageDataOp = ManageDataOp(dataName: "__link_\(publicAddress)",
            dataValue: appBundleIdentifier.data(using: .utf8))
        let manageDataSourceAccountKey = PublicKey.PUBLIC_KEY_TYPE_ED25519(WrappedData32(BCKeyUtils.key(base32: stellarAccount.publicKey!)))

        stellarAccount.sign = { message in
            return try self.stellarAccount.sign(message: message, passphrase: "")
        }

        return TransactionBuilder(source: stellarAccount, node: node)
            .add(operation: .init(sourceAccount: signOpSourceAccountKey, body: .SET_OPTIONS(signingOp)))
            .add(operation: .init(sourceAccount: manageDataSourceAccountKey, body: .MANAGE_DATA(manageDataOp)))
            .envelope(networkId: node.network.id)
    }

    public func signature(for txEnvelope: TransactionEnvelope) throws -> DecoratedSignature {
        let m = try txEnvelope.tx.hash(networkId: node.network.id)

        stellarAccount.sign = { message in
            return try self.stellarAccount.sign(message: message, passphrase: "")
        }

        guard let sign = stellarAccount.sign else {
            throw StellarError.missingSignClosure
        }

        guard let publicKey = stellarAccount.publicKey else {
            throw StellarError.missingPublicKey
        }

        let hint = WrappedData4(BCKeyUtils.key(base32: publicKey).suffix(4))

        defer {
            stellarAccount.sign = nil
        }

        return try DecoratedSignature(hint: hint, signature: sign(Array(m)))
    }
}

// MARK: - Deprecated

extension KinAccount {
    @available(*, deprecated, renamed: "buildTransaction")
    public func generateTransaction(to recipient: String,
                                    kin: Kin,
                                    memo: String? = nil,
                                    fee: Quark = 0,
                                    completion: @escaping GenerateTransactionCompletion) {
        return buildTransaction(to: recipient, kin: kin, memo: memo, fee: fee, completion: completion)
    }

    @available(*, deprecated, renamed: "buildTransaction")
    public func generateTransaction(to recipient: String, kin: Kin, memo: String? = nil, fee: Quark) -> Promise<TransactionEnvelope> {
        return buildTransaction(to: recipient, kin: kin, memo: memo, fee: fee)
    }
}
