//
//  SendTransactionOperation.swift
//  KinSDK
//
//  Created by Corey Werner on 22/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class SendTransactionOperation: AsynchronousOperation {
    var transactionInterceptor: TransactionInterceptor?
    
    var result: Result<TransactionId, Error>? {
        didSet {
            markFinished()
        }
    }

    func createTransactionProcess() -> TransactionProcess {
        fatalError("Subclass must implement")
    }

    override func workItem() {
        if isCancelled {
            markFinished()
            return
        }

        let transactionProcess = createTransactionProcess()

        if let transactionInterceptor = transactionInterceptor {
            do {
                let transactionId = try transactionInterceptor.interceptTransactionSending(process: transactionProcess)

                result = .success(transactionId)
            }
            catch {
                result = .failure(error)
            }
        }
        else {
            do {
                let transaction = try transactionProcess.transaction()
                let transactionId = try transactionProcess.send(transaction: transaction)

                result = .success(transactionId)
            }
            catch {
                result = .failure(error)
            }
        }
    }
}
