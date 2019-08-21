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

        let destination = "" // ???:
        let amount = Kin(0).toQuark() // ???:
        let memo: Memo = transactionParams.memo ?? .MEMO_NONE

        Stellar.transaction(source: account, destination: destination, amount: amount, memo: memo, fee: transactionParams.fee)
    }
}
