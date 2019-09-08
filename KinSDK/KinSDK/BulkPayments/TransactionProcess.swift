//
//  TransactionProcess.swift
//  KinSDK
//
//  Created by Corey Werner on 13/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class TransactionProcess {
    var transaction: Transaction {
        return nil!
    }

    func transaction(memo: String) -> Transaction {
        return nil!
    }

    var payments: [PaymentQueue.PendingPayment] {
        return []
    }

    func send(transaction: Transaction) -> TransactionId {
        return ""
    }

    func send(whitelistPayload: String) -> TransactionId {
        return ""
    }
}
