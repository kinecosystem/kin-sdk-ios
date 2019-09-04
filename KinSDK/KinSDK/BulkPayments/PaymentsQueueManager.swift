//
//  PaymentsQueueManager.swift
//  KinSDK
//
//  Created by Corey Werner on 15/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

protocol PaymentsQueueManagerDelegate: NSObjectProtocol {
    func paymentsQueueManager(_ manager: PaymentsQueueManager, dequeueing pendingPayments: [PendingPayment])
}

class PaymentsQueueManager {
    let maxPendingPayments = TransactionTasksQueueManager.maxPendingPaymentCount
    let maxPaymentsTime: TimeInterval
    let maxTimeoutTime: TimeInterval
    private var paymentsTimer: Timer?
    private var timeoutTimer: Timer?
    private var payments: [PendingPayment] = []

    weak var delegate: PaymentsQueueManagerDelegate?

    init(maxPaymentsTime: TimeInterval = 4, maxTimeoutTime: TimeInterval = 10) {
        self.maxPaymentsTime = maxPaymentsTime
        self.maxTimeoutTime = maxTimeoutTime
    }

    var inProgress: Bool {
        return timeoutTimer != nil || paymentsTimer != nil
    }

    var operationsCount: Int {
        return payments.count
    }

    func enqueue(pendingPayment: PendingPayment) {
        if operationsCount >= maxPendingPayments {
            dequeue()
        }

        updateTimers()

        payments.append(pendingPayment)
    }

    @objc private func dequeue() {
        removeTimers()

        delegate?.paymentsQueueManager(self, dequeueing: payments)

        payments.removeAll()
    }

    private func updateTimers() {
        if timeoutTimer == nil {
            timeoutTimer = .scheduledTimer(timeInterval: maxTimeoutTime, target: self, selector: #selector(dequeue), userInfo: nil, repeats: false)
        }

        paymentsTimer?.invalidate()
        paymentsTimer = .scheduledTimer(timeInterval: maxPaymentsTime, target: self, selector: #selector(dequeue), userInfo: nil, repeats: false)
    }

    private func removeTimers() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil

        paymentsTimer?.invalidate()
        paymentsTimer = nil
    }
}
