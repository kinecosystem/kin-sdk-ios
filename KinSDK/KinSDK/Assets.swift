//
//  Asset.swift
//  KinSDK
//
//  Created by Corey Werner on 20/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation


internal let AssetUnitDivisor: Int32 = 100_000

/**
 Kin is the native currency of the network.
 */
public typealias Kin = Decimal

extension Kin {
    public func toQuark() -> Quark {
        return (self * Decimal(AssetUnitDivisor) as NSDecimalNumber).int64Value
    }
}

/**
 Quark is the smallest amount unit. It is one-hundred-thousandth of a Kin: `1/100000` or `0.00001`.
 */
// ???: should this be int64? one could technically have more quark than what holds in 32.
public typealias Quark = Int64

extension Quark {
    public func toKin() -> Kin {
        return Decimal(self) / Decimal(AssetUnitDivisor)
    }
}

@available(*, deprecated, renamed: "Quark")
public typealias Stroop = Quark
