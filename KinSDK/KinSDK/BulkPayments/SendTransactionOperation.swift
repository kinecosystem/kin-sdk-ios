//
//  SendTransactionOperation.swift
//  KinSDK
//
//  Created by Corey Werner on 22/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class SendTransactionOperation: AsynchronousOperation {
    var result: Result<TransactionId, Error>? {
        didSet {
            markFinished()
        }
    }

    func transactionToSend(completion: @escaping (Result<BaseTransaction, Error>) -> Void) {
        fatalError("Subclass must implement")
    }

    override func workItem() {
        if isCancelled {
            markFinished()
            return
        }

        transactionToSend { result in
            if self.isCancelled {
                self.markFinished()
                return
            }

            switch result {
            case .success(let baseTransaction):
                self.send(transactionEnvelop: baseTransaction.envelope(), completion: { result in
                    if self.isCancelled {
                        self.markFinished()
                        return
                    }

                    switch result {
                    case .success(let transactionId):
                        self.result = .success(transactionId)

                    case .failure(let error):
                        self.result = .failure(error)
                    }
                })

            case .failure(let error):
                self.result = .failure(error)
            }
        }
    }

    private func send(transactionEnvelop: Transaction.Envelope, completion: @escaping (Result<TransactionId, Error>) -> Void) {
        Stellar.postTransaction(envelope: transactionEnvelop)
            .then { transactionId -> Void in
                completion(.success(transactionId))
            }
            .error { error in
                if let error = error as? PaymentError, error == .PAYMENT_UNDERFUNDED {
                    completion(.failure(KinError.insufficientFunds))
                    return
                }

                completion(.failure(KinError.paymentFailed(error)))
        }
    }
}
