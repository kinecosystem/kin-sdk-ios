//
//  PaymentQueueTransactionProcess.swift
//  KinSDK
//
//  Created by Corey Werner on 05/09/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class PaymentQueueTransactionProcess: TransactionProcess {
    public let pendingPayments: [PendingPayment]
    let fee: Quark
    let essentials: Essentials

    init(pendingPayments: [PendingPayment], fee: Quark, essentials: Essentials) {
        self.pendingPayments = pendingPayments
        self.fee = fee
        self.essentials = essentials

        super.init(stellar: essentials.stellar)
    }

    public override func transaction() throws -> BatchPaymentTransaction {
        return try transaction(memo: nil)
    }

    public func transaction(memo memoString: String?) throws -> BatchPaymentTransaction {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        var result: Result<BatchPaymentTransaction, Error> = .failure(KinError.internalInconsistency)

        var memo: Memo = .MEMO_NONE

        if let memoString = memoString {
            memo = try Memo(memoString)
        }

        essentials.stellar.transaction(source: essentials.stellarAccount, pendingPayments: pendingPayments, memo: memo, fee: fee)
            .then { transaction in
                result = .success(transaction)
                dispatchGroup.leave()
            }
            .error { error in
                result = .failure(error)
                dispatchGroup.leave()
        }

        dispatchGroup.wait()

        switch result {
        case .success(let transaction):
            return transaction
        case .failure(let error):
            throw error
        }
    }
}
