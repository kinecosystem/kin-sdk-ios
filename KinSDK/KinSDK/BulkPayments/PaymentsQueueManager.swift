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
    let maxPendingPayments = 100
    let maxDelayBetweenPayments: TimeInterval = 4
    let maxTimeout: TimeInterval = 10
    private var delayBetweenPaymentsTimer: Timer?
    private var timeoutTimer: Timer?
    private var payments: [PendingPayment] = []

    weak var delegate: PaymentsQueueManagerDelegate?

    var inProgress: Bool {
        return timeoutTimer != nil || delayBetweenPaymentsTimer != nil
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
            timeoutTimer = .scheduledTimer(timeInterval: maxTimeout, target: self, selector: #selector(dequeue), userInfo: nil, repeats: false)
        }

        delayBetweenPaymentsTimer?.invalidate()
        delayBetweenPaymentsTimer = .scheduledTimer(timeInterval: maxDelayBetweenPayments, target: self, selector: #selector(dequeue), userInfo: nil, repeats: false)
    }

    private func removeTimers() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil

        delayBetweenPaymentsTimer?.invalidate()
        delayBetweenPaymentsTimer = nil
    }
}