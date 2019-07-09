//
//  TransactionFactory.swift
//  KinSDK
//
//  Created by Corey Werner on 09/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class TransactionFactory {
    // ???: should this function exist on the `Transaction.Envelope` class?
    public static func decode(transactionEnvelope: Transaction.Envelope) -> BaseTransaction {
        do {
            return try PaymentTransaction(transaction: transactionEnvelope.tx)
        }
        catch {
            return RawTransaction(transaction: transactionEnvelope.tx)
        }
    }
}
