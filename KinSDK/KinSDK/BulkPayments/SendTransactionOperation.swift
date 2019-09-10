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

        do {
            let transactionProcess = createTransactionProcess()
            let transactionId: TransactionId

            if let transactionInterceptor = transactionInterceptor {
                transactionId = try transactionInterceptor.interceptTransactionSending(process: transactionProcess)
            }
            else {
                let transaction = try transactionProcess.transaction()
                transactionId = try transactionProcess.send(transaction: transaction)
            }

            result = .success(transactionId)
        }
        catch {
            result = .failure(error)
        }
    }
}
