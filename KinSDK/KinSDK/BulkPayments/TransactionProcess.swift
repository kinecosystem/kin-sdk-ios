//
//  TransactionProcess.swift
//  KinSDK
//
//  Created by Corey Werner on 13/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class TransactionProcess {
    let account: StellarAccount

    init(account: StellarAccount) {
        self.account = account
    }

    public func transaction() throws -> BaseTransaction {
        fatalError("Subclass must implement")
    }

    public func send(transaction: BaseTransaction) throws -> TransactionId {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        var result: Result<TransactionId, Error> = .failure(KinError.internalInconsistency)

        Stellar.postTransaction(envelope: transaction.envelope())
            .then { transactionId -> Void in
                result = .success(transactionId)
                dispatchGroup.leave()
            }
            .error { error in
                if let error = error as? PaymentError, error == .PAYMENT_UNDERFUNDED {
                    result = .failure(KinError.insufficientFunds)
                }
                else {
                    result = .failure(KinError.paymentFailed(error))
                }

                dispatchGroup.leave()
        }

        dispatchGroup.wait()

        switch result {
        case .success(let transactionId):
            return transactionId
        case .failure(let error):
            throw error
        }
    }

//    public func send(whitelistTransaction: Data) -> Result<TransactionId, Error> {
//        return Result!
//    }
}
