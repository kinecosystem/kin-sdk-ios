//
//  Stellar.swift
//  StellarKit
//
//  Created by Kin Foundation
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation
import KinUtil

class Stellar: StellarProtocol {
    func transaction(sourceStellarAccount: StellarAccount, destinationPublicAddess: String, amount: Kin, memo: Memo = .MEMO_NONE, fee: Quark) -> Promise<PaymentTransaction> {
        return balance(publicAddress: destinationPublicAddess)
            .then { _ -> Promise<Transaction> in
                let op = Operation.payment(destination: destinationPublicAddess,
                                           amount: amount,
                                           sourcePublicAddress: sourceStellarAccount.publicKey)

                return TransactionBuilder(sourcePublicAddress: sourceStellarAccount.publicKey, stellar: self)
                    .set(memo: memo)
                    .set(fee: fee)
                    .add(operation: op)
                    .build()
            }
            .then { transaction -> Promise<PaymentTransaction> in
                let baseTransaction = try PaymentTransaction(tryWrapping: transaction)
                try baseTransaction.addSignature(account: sourceStellarAccount)

                return Promise(baseTransaction)
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

    func transaction(sourceStellarAccount: StellarAccount, pendingPayments: [PendingPayment], memo: Memo = .MEMO_NONE, fee: Quark) -> Promise<BatchPaymentTransaction> {
        guard pendingPayments.count > 0 else {
            return Promise(StellarError.missingPayment)
        }

        return TransactionBuilder(sourcePublicAddress: sourceStellarAccount.publicKey, stellar: self)
            .set(memo: memo)
            .set(fee: fee)
            .add(operations: pendingPayments.map { Operation.payment(pendingPayment: $0) })
            .build()
            .then { transaction -> Promise<BatchPaymentTransaction> in
                let batchPaymentTransaction = try BatchPaymentTransaction(tryWrapping: transaction, sourcePublicAddress: sourceStellarAccount.publicKey!)
                try batchPaymentTransaction.addSignature(account: sourceStellarAccount)

                return Promise(batchPaymentTransaction)
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

    func postTransaction(envelope: Transaction.Envelope) -> Promise<TransactionId> {
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

    func balance(publicAddress: String) -> Promise<Kin> {
        return accountDetails(publicAddress: publicAddress)
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

    func accountData(publicAddress: String) -> Promise<AccountData> {
        let url = Endpoint().account(publicAddress).url

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

    func accountDetails(publicAddress: String) -> Promise<AccountDetails> {
        let url = Endpoint().account(publicAddress).url

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

    func txWatch(publicAddress: String? = nil, lastEventId: String?) -> EventWatcher<TxEvent> {
        let url = Endpoint().account(publicAddress).transactions().cursor(lastEventId).url

        return EventWatcher(eventSource: StellarEventSource(url: url))
    }

    func paymentWatch(publicAddress: String? = nil, lastEventId: String?) -> EventWatcher<PaymentEvent> {
        let url = Endpoint().account(publicAddress).payments().cursor(lastEventId).url

        return EventWatcher(eventSource: StellarEventSource(url: url))
    }

    func sequence(publicAddress: String, seqNum: UInt64 = 0) -> Promise<UInt64> {
        if seqNum > 0 {
            return Promise().signal(seqNum)
        }

        return accountDetails(publicAddress: publicAddress)
            .then { accountDetails in
                return Promise<UInt64>().signal(accountDetails.seqNum + 1)
        }
    }

    func sign(transaction: Transaction, signer: StellarAccount) throws -> Transaction.Envelope {
        var transaction = transaction
        try transaction.sign(account: signer)
        return transaction.envelope()
    }

    func issue(request: URLRequest) -> Promise<Data> {
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

    func networkParameters() -> Promise<NetworkParameters> {
        let url = Endpoint().ledgers().order(.descending).limit(1).url

        return issue(request: URLRequest(url: url))
            .then { data in
                if let horizonError = try? JSONDecoder().decode(HorizonError.self, from: data) {
                    throw StellarError.unknownError(horizonError)
                }

                return try Promise(JSONDecoder().decode(NetworkParameters.self, from: data))
        }
    }

    private var _minFee: Quark?

    func minFee() -> Promise<Quark> {
        let promise = Promise<Quark>()

        if let minFee = _minFee {
            promise.signal(minFee)
        }
        else {
            networkParameters()
                .then { [weak self] networkParameters in
                    self?._minFee = networkParameters.baseFee
                    promise.signal(networkParameters.baseFee)
                }
                .error { error in
                    promise.signal(error)
            }
        }

        return promise
    }
}
