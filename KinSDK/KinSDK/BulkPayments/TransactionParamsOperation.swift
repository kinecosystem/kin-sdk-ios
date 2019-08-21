//
//  TransactionParamsOperation.swift
//  KinSDK
//
//  Created by Corey Werner on 18/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class TransactionParamsOperation: Foundation.Operation {
    let transactionParams: SendTransactionParams
    let account: StellarAccount

    init(_ transactionParams: SendTransactionParams, account: StellarAccount) {
        self.transactionParams = transactionParams
        self.account = account

        super.init()

        queuePriority = .high
        name = "Transaction Params Operation"
    }

    override func main() {
        if isCancelled {
            return
        }

        if let operation = transactionParams.operations.first {
            switch operation.body {
            case .PAYMENT(let paymentOp):
                let memo: Memo = transactionParams.memo ?? .MEMO_NONE

                Stellar.transaction(source: account, destination: paymentOp.destination.publicKey, amount: paymentOp.amount, memo: memo, fee: transactionParams.fee)

            default:
                break
            }
        }
    }
}
