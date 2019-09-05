//
//  TransactionProcess.swift
//  KinSDK
//
//  Created by Corey Werner on 13/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class TransactionProcess {
    public func transaction() -> BaseTransaction {
        return nil!
    }

    public func send(transaction: BaseTransaction) -> TransactionId {
        return ""
    }

    public func send(whitelistPayload: String) -> TransactionId {
        return ""
    }
}
