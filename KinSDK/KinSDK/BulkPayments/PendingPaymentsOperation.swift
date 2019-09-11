//
//  PendingPaymentsOperation.swift
//  KinSDK
//
//  Created by Corey Werner on 18/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

final class PendingPaymentsOperation: SendTransactionOperation<PaymentQueueTransactionProcess> {
    private(set) var pendingPayments: [PendingPayment]
    let fee: Quark
    let essentials: Essentials

    init(_ pendingPayments: [PendingPayment], fee: Quark, essentials: Essentials) {
        self.pendingPayments = pendingPayments
        self.fee = fee
        self.essentials = essentials

        super.init()

        // TODO: test priority
        queuePriority = .normal
        name = "Pending Payments Operation"
    }

    override func createTransactionProcess() -> PaymentQueueTransactionProcess {
        return PaymentQueueTransactionProcess(pendingPayments: pendingPayments, fee: fee, essentials: essentials)
    }

    // TODO: needs tests
    @discardableResult
    func attemptToAdd(_ pendingPayment: PendingPayment) -> Bool {
        guard isReady && !isCancelled else {
            return false
        }

        pendingPayments.append(pendingPayment)

        return true
    }

    @discardableResult
    func attemptToAdd(_ pendingPayments: [PendingPayment]) -> Bool {
        guard isReady && !isCancelled else {
            return false
        }

        self.pendingPayments += pendingPayments

        return true
    }
}
