//
//  TransactionTasksQueueManager.swift
//  KinSDK
//
//  Created by Corey Werner on 15/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class TransactionTasksQueueManager {
    let account: StellarAccount

    init(account: StellarAccount) {
        self.account = account
    }

    private lazy var tasksQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Transaction Tasks Queue Manager"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    func enqueue(pendingPayments: [PendingPayment]) {
        pendingPayments.forEach {
            let operation = PendingPaymentOperation($0, account: account)
            operation.completionBlock = {
                
            }
            tasksQueue.addOperation(operation)
        }
    }

    func enqueue(transactionParams: SendTransactionParams) -> TransactionParamsOperation {
        let operation = TransactionParamsOperation(transactionParams, account: account)
        tasksQueue.addOperation(operation)
        return operation
    }

    func processMessage() {

    }
}
