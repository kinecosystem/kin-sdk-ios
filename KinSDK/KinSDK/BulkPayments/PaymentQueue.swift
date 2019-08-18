//
//  PaymentQueue.swift
//  KinSDK
//
//  Created by Corey Werner on 30/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public protocol PaymentQueueDelegate: NSObjectProtocol {
    func paymentEnqueued(pendingPayment: PendingPayment)
    func transactionSend(transaction: BatchPaymentTransaction, payments: [PendingPayment])
    func transactionSendSuccess(transaction: BatchPaymentTransaction, payments: [PendingPayment])
    func transactionSendFailed(transaction: BatchPaymentTransaction, payments: [PendingPayment], error: Error)
}

public class PaymentQueue: NSObject {
    public weak var delegate: PaymentQueueDelegate?

    let sourcePublicAddress: String

    private let paymentsQueueManager = PaymentsQueueManager()
    private let transactionTasksQueueManager = TransactionTasksQueueManager()

    init(publicAddress: String) {
        self.sourcePublicAddress = publicAddress

        super.init()

        paymentsQueueManager.delegate = self
    }

    public func enqueuePayment(publicAddress: String, amount: Kin, metadata: AnyObject? = nil) throws -> PendingPayment {
        let pendingPayment = PendingPayment(destinationPublicAddress: publicAddress, sourcePublicAddress: sourcePublicAddress, amount: amount, metadata: metadata)

        paymentsQueueManager.enqueue(pendingPayment: pendingPayment)

        return pendingPayment
    }

    public func setTransactionInterceptor(_ interceptor: TransactionInterceptor) {

    }

    public var fee: Int = 0 {
        didSet {

        }
    }

    public var transactionInProgress: Bool {
        return paymentsQueueManager.inProgress
    }

    public var pendingPaymentsCount: Int {
        return paymentsQueueManager.operationsCount
    }
}

extension PaymentQueue: PaymentsQueueManagerDelegate {
    func paymentsQueueManager(_ manager: PaymentsQueueManager, dequeueing pendingPayments: [PendingPayment]) {
        transactionTasksQueueManager.enqueue(pendingPayments: pendingPayments)
    }
}