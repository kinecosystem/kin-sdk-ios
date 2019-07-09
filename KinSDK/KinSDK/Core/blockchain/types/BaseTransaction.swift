//
//  BaseTransaction.swift
//  KinSDK
//
//  Created by Corey Werner on 01/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public protocol BaseTransaction {

}

protocol InternalBaseTransaction: BaseTransaction {
    var transaction: Transaction { get set }
}

extension InternalBaseTransaction {
    public var fee: Quark {
        return transaction.fee
    }

    public func hash(networkId: Network.Id) throws -> Data {
        return try transaction.hash(networkId: networkId)
    }

    public var sequenceNumber: UInt64 {
        return transaction.seqNum
    }

    public var sourcePublicAddress: String {
        return transaction.sourceAccount.publicKey
    }

    public var timeBounds: TimeBounds? {
        return transaction.timeBounds
    }

    public func envelope() -> Transaction.Envelope {
        return transaction.envelope()
    }

    public func whitelistPayload(networkId: Network.Id) -> WhitelistPayload {
        return WhitelistPayload(transactionEnvelope: envelope(), networkId: networkId)
    }

    public mutating func addSignature(account: Account, networkId: Network.Id) throws {
        try transaction.sign(account: account, networkId: networkId)
    }

    public mutating func addSignature(kinAccount: KinAccount, networkId: Network.Id) throws {
        try transaction.sign(kinAccount: kinAccount, networkId: networkId)
    }
}
