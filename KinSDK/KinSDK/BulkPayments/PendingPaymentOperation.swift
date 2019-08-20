//
//  PendingPaymentOperation.swift
//  KinSDK
//
//  Created by Corey Werner on 18/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class PendingPaymentOperation: Foundation.Operation {
    let pendingPayment: PendingPayment
    let account: StellarAccount

    init(_ pendingPayment: PendingPayment, account: StellarAccount) {
        self.pendingPayment = pendingPayment
        self.account = account
        
        super.init()

        queuePriority = .normal
        name = "Pending Payment Operation"
    }

    override func main() {
        if isCancelled {
            return
        }

        // Send to blockchain


    }
}
