//
//  TransactionFactory.swift
//  KinSDK
//
//  Created by Corey Werner on 17/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class TransactionFactory {
    static func wrapping(transaction: Transaction) -> BaseTransaction {
        // TODO: add BatchPaymentsTransaction
        if let transaction = try? PaymentTransaction(tryWrapping: transaction) {
            return transaction
        }
        else {
            return RawTransaction(wrapping: transaction)
        }
    }
}
