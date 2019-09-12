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
    let stellar: StellarProtocol
    let stellarAccount: StellarAccount

    init(_ transactionParams: SendTransactionParams, stellar: StellarProtocol, stellarAccount: StellarAccount) {
        self.transactionParams = transactionParams
        self.stellar = stellar
        self.stellarAccount = stellarAccount

        super.init()

        queuePriority = .high
        name = "Transaction Params Operation"
    }

    override func createTransactionProcess() -> TransactionProcess {
        return TransactionParamsProcess(transactionParams: transactionParams, stellar: stellar, stellarAccount: stellarAccount)
    }
}
