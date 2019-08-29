//
//  SendTransactionParams.swift
//  KinSDK
//
//  Created by Corey Werner on 12/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public struct SendTransactionParams {
    public let operations: [Operation]
    public let fee: Quark
    public let memo: Memo?
}

// MARK: - Factory

extension SendTransactionParams {
    public static func createSendPaymentParams(publicAddress: String, amount: Kin, fee: Quark, memo: String? = nil) throws -> SendTransactionParams {
        var m: Memo?

        if let memo = memo {
            m = try Memo(memo)
        }

        let operation = Operation.payment(destination: publicAddress, amount: amount)
        
        return SendTransactionParams(operations: [operation], fee: fee, memo: m)
    }
}
