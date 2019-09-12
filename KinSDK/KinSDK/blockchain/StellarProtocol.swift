//
//  StellarProtocol.swift
//  KinSDK
//
//  Created by Corey Werner on 12/09/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

/**
 `StellarProtocol` provides an API for communicating with Stellar Horizon servers.
 */
protocol StellarProtocol {
    /**
     Generate a transaction envelope for the given account.

     - Parameter sourceStellarAccount: The account from which the payment will be made.
     - Parameter destinationPublicAddess: The public address of the receiving account.
     - Parameter amount: The amount to be sent.
     - Parameter memo: A short string placed in the MEMO field of the transaction.
     - Parameter fee: The fee in `Quark`s used when the transaction is not whitelisted.

     - Returns: A promise which will be signalled with the result of the operation.
     */
    func transaction(sourceStellarAccount: StellarAccount, destinationPublicAddess: String, amount: Kin, memo: Memo, fee: Quark) -> Promise<PaymentTransaction>

    /**
     Generate a transaction envelope for the given pending payments.

     - Parameter sourceStellarAccount: The account from which the payment will be made.
     - Parameter pendingPayments: The pending payments to add to the transaction.
     - Parameter memo: A short string placed in the MEMO field of the transaction.
     - Parameter fee: The fee in `Quark`s used when the transaction is not whitelisted.

     - Returns: A promise which will be signalled with the result of the operation.
     */
    func transaction(sourceStellarAccount: StellarAccount, pendingPayments: [PendingPayment], memo: Memo, fee: Quark) -> Promise<BatchPaymentTransaction>

    func postTransaction(envelope: Transaction.Envelope) -> Promise<TransactionId>

    /**
     Obtain the balance.

     - Parameter publicAddress: The account whose balance will be retrieved.

     - Returns: A promise which will be signalled with the result of the operation.
     */
    func balance(publicAddress: String) -> Promise<Kin>

    func accountData(publicAddress: String) -> Promise<AccountData>

    /**
     Obtain details for the given account.

     - Parameter publicAddress: The account whose details will be retrieved.

     - Returns: A promise which will be signalled with the result of the operation.
     */
    func accountDetails(publicAddress: String) -> Promise<AccountDetails>

    /**
     Observe transactions.  When `account` is non-`nil`, observations are
     limited to transactions involving the given account.

     - Parameter publicAddress: The account whose transactions will be observed.
     - Parameter lastEventId: If non-`nil`, only transactions with a later event Id will be observed.
     The string _now_ will only observe transactions completed after observation begins.

     - Returns: An instance of `TxWatch`, which contains an `Observable` which emits `TxInfo` objects.
     */
    func txWatch(publicAddress: String?, lastEventId: String?) -> EventWatcher<TxEvent>

    /**
     Observe payments.  When `account` is non-`nil`, observations are
     limited to payments involving the given account.

     - Parameter account: The account whose payments will be observed.
     - Parameter lastEventId: If non-`nil`, only payments with a later event Id will be observed.
     The string _now_ will only observe payments made after observation begins.

     - Returns: An instance of `PaymentWatch`, which contains an `Observable` which emits `PaymentEvent` objects.
     */
    func paymentWatch(publicAddress: String?, lastEventId: String?) -> EventWatcher<PaymentEvent>

    func sequence(publicAddress: String, seqNum: UInt64) -> Promise<UInt64>

    func sign(transaction: Transaction, signer: StellarAccount) throws -> Transaction.Envelope

    func issue(request: URLRequest) -> Promise<Data>

    func networkParameters() -> Promise<NetworkParameters>

    /**
     Get the minimum fee for sending a transaction.

     - Returns: The minimum fee needed to send a transaction.
     */
    func minFee() -> Promise<Quark>
}
