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
        return queue
    }()

    func enqueue(pendingPayments: [PendingPayment]) {

    }

    func enqueue(transactionParams: SendTransactionParams) {

    }
}
