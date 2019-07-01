//
//  PaymentTransaction.swift
//  KinSDK
//
//  Created by Corey Werner on 01/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class PaymentTransaction: BaseTransaction {
    var transaction: Transaction
    let operation: PaymentOp

    private static func findPaymentOperation(operations: [Operation]) -> PaymentOp? {
        for operation in operations {
            if case let Operation.Body.PAYMENT(paymentOperation) = operation.body {
                return paymentOperation
            }
        }

        return nil
    }

    init(transaction: Transaction) throws {
        guard let operation = PaymentTransaction.findPaymentOperation(operations: transaction.operations) else {
            throw StellarError.decodeTransactionFailed
        }

        self.operation = operation
        self.transaction = transaction
    }

    public var amount: Int64 {
        return operation.amount
    }

    public var destinationPublicAddress: String {
        return operation.destination.publicKey
    }

    public var memo: String? {
        return transaction.memo.text
    }
}
