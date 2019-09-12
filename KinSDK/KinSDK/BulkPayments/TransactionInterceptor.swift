//
//  TransactionInterceptor.swift
//  KinSDK
//
//  Created by Corey Werner on 13/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public protocol TransactionInterceptor: NSObjectProtocol {
    func interceptTransactionSending<TxP: TransactionProcess>(process: TxP) throws -> TransactionId
}
