//
//  TransactionProcess.swift
//  KinSDK
//
//  Created by Corey Werner on 13/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public protocol TransactionProcess {
    associatedtype Tx: BaseTransaction

    func transaction() throws -> Tx
    func sendTransaction(_ transaction: BaseTransaction) throws -> TransactionId
    func sendWhitelistTransaction(data: Data) throws -> TransactionId
}

extension TransactionProcess {
    public func sendTransaction(_ transaction: BaseTransaction) throws -> TransactionId {
        return try send(transactionEnvelope: transaction.envelope())
    }

    public func sendWhitelistTransaction(data: Data) throws -> TransactionId {
        guard let data = Data(base64Encoded: data) else {
            throw KinError.internalInconsistency
        }

        let transactionEnvelope = try XDRDecoder.decode(Transaction.Envelope.self, data: data)

        return try send(transactionEnvelope: transactionEnvelope)
    }

    private func send(transactionEnvelope: Transaction.Envelope) throws -> TransactionId {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        var result: Result<TransactionId, Error> = .failure(KinError.internalInconsistency)

        Stellar.postTransaction(envelope: transactionEnvelope)
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
}
