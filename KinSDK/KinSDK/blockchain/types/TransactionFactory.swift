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
        do {
            return try PaymentTransaction(tryWrapping: transaction)
        }
        catch {
            return RawTransaction(wrapping: transaction)
        }
    }
}
