//
//  PendingPayment.swift
//  KinSDK
//
//  Created by Corey Werner on 15/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class PendingPayment {
    public let destinationPublicAddress: String
    public let sourcePublicAddress: String
    public let amount: Kin
    public let metadata: AnyObject?
    public internal(set) var status: Status = .pending

    init(destinationPublicAddress: String, sourcePublicAddress: String, amount: Kin, metadata: AnyObject?) {
        self.destinationPublicAddress = destinationPublicAddress
        self.sourcePublicAddress = sourcePublicAddress
        self.amount = amount
        self.metadata = metadata
    }

//    lazy var operation: Operation = {
//        return Operation(pendingPayment: self)
//    }()
}

extension PendingPayment {
    public enum Status {
        case pending
        case completed
        case failed
    }
}

//extension PendingPayment {
//    class Operation: Foundation.Operation {
//        let pendingPayment: PendingPayment
//
//        init(pendingPayment: PendingPayment) {
//            self.pendingPayment = pendingPayment
//
//            super.init()
//
//            queuePriority = .normal
//            name = "Pending Payment From \(pendingPayment.sourcePublicAddress) To \(pendingPayment.destinationPublicAddress)"
//        }
//    }
//}
