//
//  TransactionFactory.swift
//  KinSDK
//
//  Created by Corey Werner on 17/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class TransactionFactory {
    static func wrapping(transaction: Transaction, sourcePublicAddress: String) -> BaseTransaction {
        if let transaction = try? BatchPaymentTransaction(tryWrapping: transaction, sourcePublicAddress: sourcePublicAddress) {
            return transaction
        }
        else if let transaction = try? PaymentTransaction(tryWrapping: transaction) {
            return transaction
        }
        else {
            return RawTransaction(wrapping: transaction)
        }
    }
}
