//
//  KinAccountProtocol.swift
//  KinSDK
//
//  Created by Corey Werner on 12/09/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

/**
 `KinAccount` represents an account which holds Kin. It allows checking balance and sending Kin to
 other accounts.
 */
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
