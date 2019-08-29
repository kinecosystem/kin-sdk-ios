//
//  PaymentTransaction.swift
//  KinSDK
//
//  Created by Corey Werner on 01/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class PaymentTransaction: BaseTransaction {
    let operation: PaymentOp

    private static func findPaymentOperation(operations: [Operation]) -> PaymentOp? {
        var paymentOperations: [PaymentOp] = []

        for operation in operations {
            if case let Operation.Body.PAYMENT(paymentOperation) = operation.body {
                paymentOperations.append(paymentOperation)
            }
        }

        if paymentOperations.count == 1 {
            return paymentOperations.first
        }
        
        return nil
    }

    required init(tryWrapping transaction: Transaction) throws {
        guard let operation = PaymentTransaction.findPaymentOperation(operations: transaction.operations) else {
            throw StellarError.decodeTransactionFailed
        }

        self.operation = operation

        super.init(wrapping: transaction)
    }

    public var amount: Kin {
        return Kin(operation.amount)
    }

    public var destinationPublicAddress: String {
        return operation.destination.publicKey
    }

    public var memo: String? {
        return transaction.memo.text
    }
}
