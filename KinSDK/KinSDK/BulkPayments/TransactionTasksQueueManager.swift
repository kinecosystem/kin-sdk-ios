//
//  TransactionTasksQueueManager.swift
//  KinSDK
//
//  Created by Corey Werner on 15/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class TransactionTasksQueueManager {
    static let maxPendingPaymentCount = 100

    private lazy var tasksQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Transaction Tasks Queue Manager"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    let account: StellarAccount

    init(account: StellarAccount) {
        self.account = account
    }

    // MARK: Inspecting Operations

    var operationCount: Int {
        return tasksQueue.operationCount
    }

    var isSuspended: Bool {
        set {
            tasksQueue.isSuspended = newValue
        }
        get {
            return tasksQueue.isSuspended
        }
    }

    // MARK: Accessing Operations

    var pendingPaymentsOperations: [PendingPaymentsOperation] {
        return tasksQueue.operations.filter({ operation -> Bool in
            return operation.isKind(of: PendingPaymentsOperation.self)
        }) as? [PendingPaymentsOperation] ?? []
    }

    // MARK: Adding Operations

    func enqueue(pendingPayments: [PendingPayment], fee: Quark, transactionInterceptor: TransactionInterceptor?) {
        guard pendingPayments.count > 0 else {
            return
        }

        var pendingPayments = pendingPayments
        var arrayOfPendingPayments: [[PendingPayment]] = []
        let maxPendingPaymentCount = TransactionTasksQueueManager.maxPendingPaymentCount

        let lastPendingPaymentsOperation = tasksQueue.operations.last {
            $0.isKind(of: PendingPaymentsOperation.self) && $0.isReady && !$0.isCancelled
        } as? PendingPaymentsOperation

        let offsetCount: Int = {
            let count = lastPendingPaymentsOperation?.pendingPayments.count ?? 0
            return maxPendingPaymentCount > count ? count : 0
        }()
        let totalCount = pendingPayments.count + offsetCount
        let iterations = Int(ceil(Double(totalCount) / Double(maxPendingPaymentCount)))

        if offsetCount > 0 || iterations > 1 {
            for i in 0..<iterations {
                let start = i == 0 ? 0 : maxPendingPaymentCount * i - offsetCount
                let end = min(totalCount, maxPendingPaymentCount * (i + 1)) - offsetCount
                let pendingPaymentsSlice = Array(pendingPayments[start..<end])

                if i == 0, let operation = lastPendingPaymentsOperation {
                    operation.attemptToAdd(pendingPaymentsSlice)
                }
                else {
                    arrayOfPendingPayments.append(pendingPaymentsSlice)
                }
            }
        }
        else {
            arrayOfPendingPayments.append(pendingPayments)
        }

        arrayOfPendingPayments.forEach { pendingPayments in
            let operation = PendingPaymentsOperation(pendingPayments, fee: fee, account: account)
            operation.transactionInterceptor = transactionInterceptor
            tasksQueue.addOperation(operation)
        }
    }

    func enqueue(transactionParams: SendTransactionParams) -> TransactionParamsOperation {
        let operation = TransactionParamsOperation(transactionParams, account: account)
        tasksQueue.addOperation(operation)
        return operation
    }
}
