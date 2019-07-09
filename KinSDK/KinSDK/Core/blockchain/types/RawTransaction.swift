//
//  RawTransaction.swift
//  KinSDK
//
//  Created by Corey Werner on 01/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class RawTransaction: InternalBaseTransaction {
    var transaction: Transaction

    init(transaction: Transaction) {
        self.transaction = transaction
    }

    public var operations: [Operation] {
        return transaction.operations
    }

    public var memo: Memo {
        return transaction.memo
    }
}
