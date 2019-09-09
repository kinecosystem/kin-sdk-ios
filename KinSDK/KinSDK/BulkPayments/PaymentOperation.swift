//
//  PaymentOperation.swift
//  KinSDK
//
//  Created by Corey Werner on 14/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public struct PaymentOperation {
    public let sourcePublicAddress: String
    public let destinationPublicAddress: String
    public let amount: Kin
}
