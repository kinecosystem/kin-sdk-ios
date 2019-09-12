//
//  BatchPaymentTransaction.swift
//  KinSDK
//
//  Created by Corey Werner on 14/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class BatchPaymentTransaction: BaseTransaction {
    public let payments: [PaymentOperation]

    private static func findPaymentOperations(operations: [Operation]) -> [PaymentOp]? {
        var paymentOperations: [PaymentOp] = []

        for operation in operations {
            if case let Operation.Body.PAYMENT(paymentOperation) = operation.body {
                paymentOperations.append(paymentOperation)
            }
        }

        return paymentOperations.count > 0 ? paymentOperations : nil
    }

    required init(tryWrapping transaction: Transaction, sourcePublicAddress: String) throws {
        guard let operations = BatchPaymentTransaction.findPaymentOperations(operations: transaction.operations) else {
            throw StellarError.decodeTransactionFailed
        }

        self.payments = operations.map({ operation -> PaymentOperation in
            return PaymentOperation(sourcePublicAddress: sourcePublicAddress, destinationPublicAddress: operation.destination.publicKey, amount: Kin(operation.amount))
        })

        super.init(wrapping: transaction)
    }

    public var memo: String? {
        return transaction.memo.text
    }
}
