//
//  TransactionParamsProcess.swift
//  KinSDK
//
//  Created by Corey Werner on 08/09/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class TransactionParamsProcess: TransactionProcess {
    let transactionParams: SendTransactionParams

    init(transactionParams: SendTransactionParams, stellar: StellarProtocol) {
        self.transactionParams = transactionParams

        super.init(stellar: stellar)
    }

    override func transaction() throws -> BaseTransaction {
        var result: Result<BaseTransaction, Error> = .failure(KinError.internalInconsistency)

        if let operation = transactionParams.operations.first {
            switch operation.body {
            case .PAYMENT(let paymentOp):
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()

                let memo: Memo = transactionParams.memo ?? .MEMO_NONE

                stellar.transaction(source: stellar.stellarAccount, destination: paymentOp.destination.publicKey, amount: Kin(paymentOp.amount), memo: memo, fee: transactionParams.fee)
                    .then { baseTransaction in
                        result = .success(baseTransaction)
                        dispatchGroup.leave()
                    }
                    .error { error in
                        result = .failure(error)
                        dispatchGroup.leave()
                }

                dispatchGroup.wait()

            default:
                break
            }
        }

        switch result {
        case .success(let transaction):
            return transaction
        case .failure(let error):
            throw error
        }
    }
}
