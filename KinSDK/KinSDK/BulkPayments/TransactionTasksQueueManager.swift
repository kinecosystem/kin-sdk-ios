//
//  TransactionTasksQueueManager.swift
//  KinSDK
//
//  Created by Corey Werner on 15/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class TransactionTasksQueueManager {
    private lazy var tasksQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Transaction Tasks Queue Manager"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    func enqueue(pendingPayments: [PendingPayment]) {
        pendingPayments.forEach { tasksQueue.addOperation(PendingPaymentOperation($0)) }
    }

    func enqueue(transactionParams: SendTransactionParams) -> TransactionParamsOperation {
        let operation = TransactionParamsOperation(transactionParams)
        tasksQueue.addOperation(operation)
        return operation
    }

    func processMessage() {

    }
}
