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
    let account: StellarAccount

    init(_ pendingPayments: [PendingPayment], account: StellarAccount) {
        self.pendingPayments = pendingPayments
        self.account = account

        super.init()

        queuePriority = .normal
        name = "Pending Payments Operation"
    }

    override func transactionToSend(completion: @escaping (Result<BaseTransaction, Error>) -> Void) {
        let fee: Quark = 0 // ???:

        Stellar.transaction(source: account, pendingPayments: pendingPayments, fee: fee)
            .then { baseTransaction in
                completion(.success(baseTransaction))
            }
            .error { error in
                completion(.failure(error))
        }
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
