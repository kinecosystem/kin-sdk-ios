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
                result = .success(try transactionInterceptor.interceptTransactionSending(process: transactionProcess))
            }
            catch {
                result = .failure(error)
            }
        }
        else {
            do {
                let transaction = try transactionProcess.transaction()
                result = transactionProcess.send(transaction: transaction)
            }
            catch {
                result = .failure(error)
            }
        }
    }
}
