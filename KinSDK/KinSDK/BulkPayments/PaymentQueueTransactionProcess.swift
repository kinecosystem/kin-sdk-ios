//
//  PaymentQueueTransactionProcess.swift
//  KinSDK
//
//  Created by Corey Werner on 05/09/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class PaymentQueueTransactionProcess: TransactionProcess {
    public override func transaction() -> BatchPaymentTransaction {
        return nil!
    }

    public func transaction(memo: String) -> BatchPaymentTransaction {
        return nil!
    }

    public var pendingPayments: [PendingPayment] {
        return []
    }
}
