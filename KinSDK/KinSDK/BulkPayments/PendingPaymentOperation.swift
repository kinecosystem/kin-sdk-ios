//
//  PendingPaymentOperation.swift
//  KinSDK
//
//  Created by Corey Werner on 18/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class PendingPaymentOperation: SendTransactionOperation {
    let pendingPayment: PendingPayment
    let account: StellarAccount

    init(_ pendingPayment: PendingPayment, account: StellarAccount) {
        self.pendingPayment = pendingPayment
        self.account = account

        super.init()

        queuePriority = .normal
        name = "Pending Payment Operation"
    }

    override func transactionToSend(completion: @escaping (Result<BaseTransaction, Error>) -> Void) {
        let fee: Quark = 0 // ???:

        Stellar.transaction(source: account, destination: pendingPayment.destinationPublicAddress, amount: pendingPayment.amount, fee: fee)
            .then { baseTransaction in
                self.pendingPayment.status = .completed
                completion(.success(baseTransaction))
            }
            .error { error in
                self.pendingPayment.status = .failed
                completion(.failure(error))
        }
    }
}
