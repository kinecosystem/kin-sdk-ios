//
//  BatchPaymentTransaction.swift
//  KinSDK
//
//  Created by Corey Werner on 14/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class BatchPaymentTransaction: BaseTransaction {
    // ???: where is this PaymentOperation coming from? When is it set? Should all PaymentOp become PaymentOperation
//    public let payments: [PaymentOperation]

    private static func findPaymentOperations(operations: [Operation]) -> [PaymentOp]? {
        var paymentOperations: [PaymentOp] = []

        for operation in operations {
            if case let Operation.Body.PAYMENT(paymentOperation) = operation.body {
                paymentOperations.append(paymentOperation)
            }
        }

        return paymentOperations.count > 1 ? paymentOperations : nil
    }

    required init(tryWrapping transaction: Transaction) throws {
        guard let operations = BatchPaymentTransaction.findPaymentOperations(operations: transaction.operations) else {
            throw StellarError.decodeTransactionFailed
        }

//        self.operations = operations

        super.init(wrapping: transaction)
    }

    public var memo: String? {
        return transaction.memo.text
    }
}
