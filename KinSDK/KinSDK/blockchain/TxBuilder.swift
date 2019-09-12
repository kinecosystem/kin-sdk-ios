//
// TxBuilder.swift
// StellarKit
//
// Created by Kin Foundation.
// Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation
import KinUtil

final class TransactionBuilder {
    private let sourcePublicAddress: String
    // TODO: Stellar creates a TransactionBuilder which then uses Stellar. Fix this pattern.
    private let stellar: StellarProtocol
    private var memo: Memo?
    private var fee: Quark?
    private var timeBounds: TimeBounds?
    private var sequence: UInt64 = 0
    private var operations = [Operation]()

    init(sourcePublicAddress: String, stellar: StellarProtocol) {
        self.sourcePublicAddress = sourcePublicAddress
        self.stellar = stellar
    }

    @discardableResult
    func set(memo: Memo) -> TransactionBuilder {
        self.memo = memo

        return self
    }

    @discardableResult
    func set(fee: Quark) -> TransactionBuilder {
        self.fee = fee

        return self
    }

    @discardableResult
    func set(timeBounds: TimeBounds) -> TransactionBuilder {
        self.timeBounds = timeBounds

        return self
    }

    @discardableResult
    func set(sequence: UInt64) -> TransactionBuilder {
        self.sequence = sequence

        return self
    }

    @discardableResult
    func add(operation: Operation) -> TransactionBuilder {
        operations.append(operation)

        return self
    }

    @discardableResult
    func add(operations: [Operation]) -> TransactionBuilder {
        self.operations += operations

        return self
    }

    func build() -> Promise<Transaction> {
        let p = Promise<Transaction>()
        let pk = PublicKey.PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: sourcePublicAddress)))

        func createTransaction(sequenceNumber: UInt64, fee: Quark? = nil) -> Transaction {
            return Transaction(sourceAccount: pk,
                               seqNum: sequenceNumber,
                               timeBounds: timeBounds,
                               memo: memo ?? .MEMO_NONE,
                               fee: fee,
                               operations: operations)
        }

        if sequence > 0 {
            p.signal(createTransaction(sequenceNumber: sequence, fee: fee))
        }
        else {
            stellar.sequence(publicAddress: sourcePublicAddress, seqNum: sequence)
                .then { sequenceNumber in
                    p.signal(createTransaction(sequenceNumber: sequenceNumber))
                }
                .error { _ in
                    p.signal(StellarError.missingSequence)
            }
        }

        return p
    }
}
