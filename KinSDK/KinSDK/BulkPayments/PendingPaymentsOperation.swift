//
//  PendingPaymentsOperation.swift
//  KinSDK
//
//  Created by Corey Werner on 18/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class PendingPaymentsOperation: SendTransactionOperation {
    private(set) var pendingPayments: [PendingPayment]
    let fee: Quark
    let account: StellarAccount

    init(_ pendingPayments: [PendingPayment], fee: Quark, account: StellarAccount) {
        self.pendingPayments = pendingPayments
        self.fee = fee
        self.account = account

        super.init()

        queuePriority = .normal
        name = "Pending Payments Operation"
    }

    override func createTransactionProcess() -> TransactionProcess {
        return PaymentQueueTransactionProcess(pendingPayments: pendingPayments, fee: fee, account: account)
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
