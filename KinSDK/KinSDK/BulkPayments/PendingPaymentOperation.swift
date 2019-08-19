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

    init(_ pendingPayment: PendingPayment) {
        self.pendingPayment = pendingPayment

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
