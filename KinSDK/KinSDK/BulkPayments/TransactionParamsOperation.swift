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

    init(_ transactionParams: SendTransactionParams) {
        self.transactionParams = transactionParams

        super.init()

        queuePriority = .high
        name = "Transaction Params Operation"
    }

    override func main() {
        if isCancelled {
            return
        }

        
    }
}
