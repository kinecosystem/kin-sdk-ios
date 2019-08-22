//
//  BaseTransaction.swift
//  KinSDK
//
//  Created by Corey Werner on 01/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public class BaseTransaction {
    var transaction: Transaction

    init(wrapping transaction: Transaction) {
        self.transaction = transaction
    }

    public var fee: Quark {
        return transaction.fee
    }

    public func hash() throws -> Data {
        return try transaction.hash()
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

    public func whitelistPayload() -> WhitelistPayload {
        return WhitelistPayload(transactionEnvelope: envelope(), networkId: Network.current.id)
    }

    public func addSignature(account: StellarAccount) throws {
        try transaction.sign(account: account)
    }

    public func addSignature(kinAccount: KinAccount) throws {
        try transaction.sign(kinAccount: kinAccount)
    }
}
