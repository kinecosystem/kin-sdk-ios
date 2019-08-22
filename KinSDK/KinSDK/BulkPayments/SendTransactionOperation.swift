//
//  SendTransactionOperation.swift
//  KinSDK
//
//  Created by Corey Werner on 22/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class SendTransactionOperation: Foundation.Operation {
    func transactionToSend(completion: @escaping (Result<BaseTransaction, Error>) -> Void) {
        fatalError("Subclass must implement")
    }

    override func main() {
        if isCancelled {
            return
        }

        transactionToSend { result in
            if self.isCancelled {
                return
            }

            switch result {
            case .success(let baseTransaction):
                self.send(transactionEnvelop: baseTransaction.envelope(), completion: { result in
                    if self.isCancelled {
                        return
                    }
                    
                    switch result {
                    case .success(let transactionHash):
                        break

                    case .failure(let error):
                        self.error(error)
                    }
                })

            case .failure(let error):
                self.error(error)
            }
        }
    }

    private func send(transactionEnvelop: Transaction.Envelope, completion: @escaping (Result<String, Error>) -> Void) {
        Stellar.postTransaction(envelope: transactionEnvelop)
            .then { transactionHash -> Void in
                completion(.success(transactionHash))
            }
            .error { error in
                if let error = error as? PaymentError, error == .PAYMENT_UNDERFUNDED {
                    completion(.failure(KinError.insufficientFunds))
                    return
                }

                completion(.failure(KinError.paymentFailed(error)))
        }
    }

    private func error(_ error: Error) {

    }
}
