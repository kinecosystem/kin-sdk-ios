//
//  TransactionParamsOperation.swift
//  KinSDK
//
//  Created by Corey Werner on 18/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class TransactionParamsOperation: SendTransactionOperation {
    let transactionParams: SendTransactionParams
    let account: StellarAccount

    init(_ transactionParams: SendTransactionParams, account: StellarAccount) {
        self.transactionParams = transactionParams
        self.account = account

        super.init()

        queuePriority = .high
        name = "Transaction Params Operation"
    }

    override func createTransactionProcess() -> TransactionProcess {
        return TransactionParamsProcess(transactionParams: transactionParams, account: account)
    }
}
