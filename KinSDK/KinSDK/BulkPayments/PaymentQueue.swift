//
//  PaymentQueue.swift
//  KinSDK
//
//  Created by Corey Werner on 30/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public protocol PaymentQueueDelegate: NSObjectProtocol {
    func paymentEnqueued(pendingPayment: PaymentQueue.PendingPayment)
    func transactionSend(transaction: BatchPaymentTransaction, payments: [PaymentQueue.PendingPayment])
    func transactionSendSuccess(transaction: BatchPaymentTransaction, payments: [PaymentQueue.PendingPayment])
    func transactionSendFailed(transaction: BatchPaymentTransaction, payments: [PaymentQueue.PendingPayment], error: Error)
}

public class PaymentQueue {
    public weak var delegate: PaymentQueue?

    public func enqueuePayment(publicAddress: String, amount: Kin, metadata: AnyObject? = nil) throws {

    }

    public func setTransactionInterceptor(_ interceptor: TransactionInterceptor) {

    }

    public var fee: Int = 0 {
        didSet {

        }
    }

    public var status: Status {
        return Status()
    }
}

extension PaymentQueue {
    public class Status {
        public var transactionInProgress: Bool {
            return false
        }

        public var pendingPaymentsCount: Int {
            return 0
        }
    }
}

extension PaymentQueue {
    // ???: change to struct
    public class PendingPayment {
        public var destinationPublicKey: String {
            return ""
        }

        public var sourcePublicKey: String {
            return ""
        }

        public var amount: Kin {
            return 0
        }

        public var operationIndex: Int {
            return 0
        }

        public func transaction() -> BatchPaymentTransaction {
            return nil!
        }

        public var metaData: Any {
            return {}
        }

        public var status: Status {
            return .pending
        }
    }
}

extension PaymentQueue.PendingPayment {
    public enum Status {
        case pending
        case completed
        case failed
    }
}
