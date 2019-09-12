//
//  Asset.swift
//  KinSDK
//
//  Created by Corey Werner on 20/08/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

/**
 Kin is the native currency of the network.
 */
public typealias Kin = Decimal

extension Kin {
    /**
     Convert `Kin` into `Quark`.

     This value should only be used to fees.
     */
    public func toQuark() -> Quark {
        return (self * Decimal(AssetUnitDivisor) as NSDecimalNumber).uint32Value
    }

    func toQuarkAsBlockchainUnit() -> Int64 {
        return (self * Decimal(AssetUnitDivisor) as NSDecimalNumber).int64Value
    }
}

/**
 Quark is the smallest amount unit. It is one-hundred-thousandth of a Kin: `1/100000` or `0.00001`.
 */
public typealias Quark = UInt32

extension Quark {
    public func toKin() -> Kin {
        return Decimal(self) / Decimal(AssetUnitDivisor)
    }
}

@available(*, deprecated, renamed: "Quark")
public typealias Stroop = Quark

let AssetUnitDivisor: UInt32 = 100_000
