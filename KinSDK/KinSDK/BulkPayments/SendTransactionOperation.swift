//
//  SendTransactionOperation.swift
//  KinSDK
//
//  Created by Corey Werner on 22/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class SendTransactionOperation: Foundation.Operation {
    var transactionInterceptor: TransactionInterceptor?

    var result: Result<TransactionId, Error>?

    func createTransactionProcess() -> TransactionProcess {
        fatalError("Subclass must implement")
    }

    override func main() {
        if isCancelled {
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
                transactionId = try transactionProcess.sendTransaction(transaction)
            }

            result = .success(transactionId)
        }
        catch {
            result = .failure(error)
        }
    }
}
