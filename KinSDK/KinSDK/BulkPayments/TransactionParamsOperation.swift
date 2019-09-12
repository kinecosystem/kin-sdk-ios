//
//  TransactionParamsOperation.swift
//  KinSDK
//
//  Created by Corey Werner on 18/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

final class TransactionParamsOperation: SendTransactionOperation {
    let transactionParams: SendTransactionParams
    let essentials: Essentials

    init(_ transactionParams: SendTransactionParams, essentials: Essentials) {
        self.transactionParams = transactionParams
        self.essentials = essentials

        super.init()

        queuePriority = .high
        name = "Transaction Params Operation"
    }

    override func createTransactionProcess() -> TransactionProcess {
        return TransactionParamsProcess(transactionParams: transactionParams, essentials: essentials)
    }
}
