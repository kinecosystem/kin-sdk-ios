//
//  BatchPaymentTransaction.swift
//  KinSDK
//
//  Created by Corey Werner on 14/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class BatchPaymentTransaction: BaseTransaction {
    public var payments: [PaymentOperation] {
        return []
    }

    public var memo: String {
        return ""
    }
}

