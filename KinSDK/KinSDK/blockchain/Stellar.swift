//
//  Stellar.swift
//  StellarKit
//
//  Created by Kin Foundation
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation
import KinUtil

/**
 `Stellar` provides an API for communicating with Stellar Horizon servers, with an emphasis on
 supporting non-native assets.
 */
public enum Stellar {
    /**
     Generate a transaction envelope for the given account.

     - Parameter source: The account from which the payment will be made.
     - Parameter destination: The public key of the receiving account, as a base32 string.
     - Parameter amount: The amount to be sent.
     - Parameter memo: A short string placed in the MEMO field of the transaction.
     - Parameter fee: The fee in `Quark`s used when the transaction is not whitelisted.

     - Returns: A promise which will be signalled with the result of the operation.
     */
    public static func transaction(source: StellarAccount,
                                   destination: String,
                                   amount: Kin,
                                   memo: Memo = .MEMO_NONE,
                                   fee: Quark) -> Promise<BaseTransaction> {
        return balance(account: destination)
            .then { _ -> Promise<BaseTransaction> in
                let op = Operation.payment(destination: destination,
                                           amount: amount,
                                           sourcePublicAddress: source.publicKey)

                return TransactionBuilder(sourcePublicAddress: source.publicKey)
                    .set(memo: memo)
                    .set(fee: fee)
                    .add(operation: op)
                    .build(BaseTransaction.self)
            }
            .then { transaction -> Promise<BaseTransaction> in
                try transaction.addSignature(account: source)

                return Promise(transaction)
            }
            .mapError({ error -> Error in
                switch error {
                case StellarError.missingAccount, StellarError.missingBalance:
                    return StellarError.destinationNotReadyForAsset(error)
                default:
                    return error
                }
            })
    }

    /**
     Generate a transaction envelope for the given pending payments.

     - Parameter source: The account from which the payment will be made.
     - Parameter pendingPayments: The pending payments to add to the transaction.
     - Parameter memo: A short string placed in the MEMO field of the transaction.
     - Parameter fee: The fee in `Quark`s used when the transaction is not whitelisted.

     - Returns: A promise which will be signalled with the result of the operation.
     */
    static func transaction(source: StellarAccount, pendingPayments: [PendingPayment], memo: Memo = .MEMO_NONE, fee: Quark) -> Promise<BatchPaymentTransaction> {
        guard let firstPendingPayment = pendingPayments.first else {
            return Promise(StellarError.missingPayment)
        }

        return TransactionBuilder(sourcePublicAddress: firstPendingPayment.sourcePublicAddress)
            .set(memo: memo)
            .set(fee: fee)
            .add(operations: pendingPayments.map { Operation.payment(pendingPayment: $0) })
            .build(BatchPaymentTransaction.self)
            .then { transaction -> Promise<BatchPaymentTransaction> in
                try transaction.addSignature(account: source)

                return Promise(transaction)
            }
            .mapError({ error -> Error in
                switch error {
                case StellarError.missingAccount, StellarError.missingBalance:
                    return StellarError.destinationNotReadyForAsset(error)
                default:
                    return error
                }
            })
    }

    /**
     Obtain the balance.

     - parameter account: The `Account` whose balance will be retrieved.

     - Returns: A promise which will be signalled with the result of the operation.
     */
    public static func balance(account: String) -> Promise<Kin> {
        return accountDetails(account: account)
            .then { accountDetails in
                let p = Promise<Kin>()

                for balance in accountDetails.balances {
                    if balance.assetType == Asset.native.description {
                        return p.signal(balance.balanceNum)
                    }
                }

                return p.signal(StellarError.missingBalance)
        }
    }

    static func accountData(account: String) -> Promise<AccountData> {
        let url = Endpoint().account(account).url

        return issue(request: URLRequest(url: url))
            .then { data -> Promise<AccountResponse> in
                if let horizonError = try? JSONDecoder().decode(HorizonError.self, from: data) {
                    if case 400...404 = horizonError.status {
                        throw StellarError.invalidAccount
                    }
                    else {
                        throw StellarError.unknownError(horizonError)
                    }
                }

                return try Promise(JSONDecoder().decode(AccountResponse.self, from: data))
            }
            .then { accountResponse in
                return Promise(AccountData(publicAddress: accountResponse.keyPair,
                                           sequenceNumber: accountResponse.sequenceNumber,
                                           pagingToken: accountResponse.pagingToken,
                                           subentryCount: accountResponse.subentryCount,
                                           thresholds: accountResponse.thresholds,
                                           flags: accountResponse.flags,
                                           balances: accountResponse.balances,
                                           signers: accountResponse.signers,
                                           data: accountResponse.data))
        }
    }

    /**
     Obtain details for the given account.

     - parameter account: The `Account` whose details will be retrieved.

     - Returns: A promise which will be signalled with the result of the operation.
     */
    public static func accountDetails(account: String) -> Promise<AccountDetails> {
        let url = Endpoint().account(account).url

        return issue(request: URLRequest(url: url))
            .then { data in
                if let horizonError = try? JSONDecoder().decode(HorizonError.self, from: data) {
                    if horizonError.status == 404 {
                        throw StellarError.missingAccount
                    }
                    else {
                        throw StellarError.unknownError(horizonError)
                    }
                }

                return try Promise<AccountDetails>(JSONDecoder().decode(AccountDetails.self, from: data))
        }
    }

    /**
     Observe transactions.  When `account` is non-`nil`, observations are
     limited to transactions involving the given account.

     - parameter account: The `Account` whose transactions will be observed.  Optional.
     - parameter lastEventId: If non-`nil`, only transactions with a later event Id will be observed.
     The string _now_ will only observe transactions completed after observation begins.

     - Returns: An instance of `TxWatch`, which contains an `Observable` which emits `TxInfo` objects.
     */
    public static func txWatch(account: String? = nil, lastEventId: String?) -> EventWatcher<TxEvent> {
        let url = Endpoint().account(account).transactions().cursor(lastEventId).url

        return EventWatcher(eventSource: StellarEventSource(url: url))
    }

    /**
     Observe payments.  When `account` is non-`nil`, observations are
     limited to payments involving the given account.

     - parameter account: The `Account` whose payments will be observed.  Optional.
     - parameter lastEventId: If non-`nil`, only payments with a later event Id will be observed.
     The string _now_ will only observe payments made after observation begins.

     - Returns: An instance of `PaymentWatch`, which contains an `Observable` which emits `PaymentEvent` objects.
     */
    public static func paymentWatch(account: String? = nil, lastEventId: String?) -> EventWatcher<PaymentEvent> {
        let url = Endpoint().account(account).payments().cursor(lastEventId).url

        return EventWatcher(eventSource: StellarEventSource(url: url))
    }

    //MARK: -

    public static func sequence(account: String, seqNum: UInt64 = 0) -> Promise<UInt64> {
        if seqNum > 0 {
            return Promise().signal(seqNum)
        }

        return accountDetails(account: account)
            .then { accountDetails in
                return Promise<UInt64>().signal(accountDetails.seqNum + 1)
        }
    }

    public static func networkParameters() -> Promise<NetworkParameters> {
        let url = Endpoint().ledgers().order(.descending).limit(1).url

        return issue(request: URLRequest(url: url))
            .then { data in
                if let horizonError = try? JSONDecoder().decode(HorizonError.self, from: data) {
                    throw StellarError.unknownError(horizonError)
                }

                return try Promise(JSONDecoder().decode(NetworkParameters.self, from: data))
        }
    }

    public static func sign(transaction: Transaction, signer: StellarAccount) throws -> Transaction.Envelope {
        var transaction = transaction
        try transaction.sign(account: signer)
        return transaction.envelope()
    }

    public static func postTransaction(envelope: Transaction.Envelope) -> Promise<TransactionId> {
        let envelopeData: Data
        do {
            envelopeData = try Data(XDREncoder.encode(envelope))
        }
        catch {
            return Promise<String>(error)
        }

        guard let urlEncodedEnvelope = envelopeData.base64EncodedString().urlEncoded else {
            return Promise<String>(StellarError.urlEncodingFailed)
        }

        guard let httpBody = ("tx=" + urlEncodedEnvelope).data(using: .utf8) else {
            return Promise<String>(StellarError.dataEncodingFailed)
        }

        var request = URLRequest(url: Endpoint().transactions().url)
        request.httpMethod = "POST"
        request.httpBody = httpBody

        return issue(request: request)
            .then { data in
                if let horizonError = try? JSONDecoder().decode(HorizonError.self, from: data),
                    let resultXDR = horizonError.extras?.resultXDR,
                    let error = errorFromResponse(resultXDR: resultXDR)
                {
                    throw error
                }

                do {
                    let txResponse = try JSONDecoder().decode(TransactionResponse.self, from: data)

                    return Promise<TransactionId>(txResponse.hash)
                }
                catch {
                    throw error
                }
        }
    }

    /**
     Cached minimum fee.
     */
    private static var _minFee: Quark?

    /**
     Get the minimum fee for sending a transaction.

     - Returns: The minimum fee needed to send a transaction.
     */
    public static func minFee() -> Promise<Quark> {
        let promise = Promise<Quark>()

        if let minFee = _minFee {
            promise.signal(minFee)
        }
        else {
            Stellar.networkParameters()
                .then { networkParameters in
                    _minFee = networkParameters.baseFee
                    promise.signal(networkParameters.baseFee)
                }
                .error { error in
                    promise.signal(error)
            }
        }

        return promise
    }

    static func issue(request: URLRequest) -> Promise<Data> {
        let p = Promise<Data>()

        URLSession
            .shared
            .kinDataTask(with: request, completionHandler: { (data, _, error) in
                if let error = error {
                    p.signal(error)

                    return
                }

                guard let data = data else {
                    p.signal(StellarError.internalInconsistency)

                    return
                }

                p.signal(data)
            })
            .resume()

        return p
    }
}
