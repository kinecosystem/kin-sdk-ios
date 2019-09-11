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

    let essentials: Essentials

    private let paymentsQueueManager = PaymentsQueueManager()
    private lazy var transactionTasksQueueManager: TransactionTasksQueueManager = {
        return TransactionTasksQueueManager(essentials: essentials)
    }()

    init(essentials: Essentials) {
        self.essentials = essentials

        super.init()

        paymentsQueueManager.delegate = self
    }

    // MARK: Enqueuing

    public func enqueuePayment(publicAddress: String, amount: Kin, metadata: AnyObject? = nil) throws -> PendingPayment {
        let pendingPayment = PendingPayment(destinationPublicAddress: publicAddress, sourcePublicAddress: essentials.stellarAccount.publicKey!, amount: amount, metadata: metadata)

        paymentsQueueManager.enqueue(pendingPayment: pendingPayment)

        return pendingPayment
    }

    func enqueueTransactionParams(_ params: SendTransactionParams, completion: @escaping (Result<TransactionId, Error>) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            let transactionParamsOperation = self.transactionTasksQueueManager.enqueue(transactionParams: params)

            transactionParamsOperation.completionBlock = {
                DispatchQueue.main.async {
                    if transactionParamsOperation.isCancelled {
                        completion(.failure(KinError.transactionOperationCancelled))
                        return
                    }

                    guard let result = transactionParamsOperation.result else {
                        // This should never happen.
                        completion(.failure(KinError.internalInconsistency))
                        return
                    }

                    completion(result)
                }
            }
        }
    }

    // MARK: Inspecting

    public var transactionInProgress: Bool {
        return transactionTasksQueueManager.inProgress
    }

    public var pendingPaymentsCount: Int {
        return paymentsQueueManager.operationsCount
    }

    // MARK: Operation Properties

    /**
     - Note: The delegate functions will be called from a background thread.
     */
    weak public var transactionInterceptor: TransactionInterceptor?

    public var fee: Quark = 0
}

extension PaymentQueue: PaymentsQueueManagerDelegate {
    func paymentsQueueManager(_ manager: PaymentsQueueManager, dequeueing pendingPayments: [PendingPayment]) {
        DispatchQueue.global(qos: .utility).async {
            func enqueue() {
                self.transactionTasksQueueManager.enqueue(pendingPayments: pendingPayments, fee: self.fee, transactionInterceptor: self.transactionInterceptor)
            }

            if self.fee == 0 {
                self.essentials.stellar.minFee().then({ self.fee = $0 }).finally({ enqueue() })
            }
            else {
                enqueue()
            }
        }
    }
}
