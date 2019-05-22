//
// TxBuilder.swift
// StellarKit
//
// Created by Kin Foundation.
// Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation
import KinUtil

@available(*, deprecated, renamed: "TransactionBuilder")
public class TxBuilder: TransactionBuilder {

}

// TODO: uncomment final after removing TxBuilder
public /*final*/ class TransactionBuilder {
    private var source: Account
    private var memo: Memo?
    private var fee: Stroop?
    private var timeBounds: TimeBounds?
    private var sequence: UInt64 = 0
    private var operations = [Operation]()

    private var node: Stellar.Node

    public init(source: Account, node: Stellar.Node) {
        self.source = source
        self.node = node
    }

    public func set(memo: Memo) -> TransactionBuilder {
        self.memo = memo

        return self
    }

    public func set(fee: Stroop) -> TransactionBuilder {
        self.fee = fee

        return self
    }

    public func set(timeBounds: TimeBounds) -> TransactionBuilder {
        self.timeBounds = timeBounds

        return self
    }

    public func set(sequence: UInt64) -> TransactionBuilder {
        self.sequence = sequence

        return self
    }

    public func add(operation: Operation) -> TransactionBuilder {
        operations.append(operation)

        return self
    }

    public func add(operations: [Operation]) -> TransactionBuilder {
        self.operations += operations

        return self
    }

    @available(*, deprecated, renamed: "build")
    public func tx() -> Promise<Transaction> {
        return build()
    }

    public func build() -> Promise<Transaction> {
        let p = Promise<Transaction>()

        guard let sourceKey = source.publicKey else {
            p.signal(StellarError.missingPublicKey)

            return p
        }

        let pk = PublicKey.PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: sourceKey)))

        if sequence > 0 {
            p.signal(Transaction(sourceAccount: pk,
                                 seqNum: sequence,
                                 timeBounds: timeBounds,
                                 memo: memo ?? .MEMO_NONE,
                                 fee: fee,
                                 operations: operations))
        }
        else {
            Stellar.sequence(account: sourceKey, seqNum: sequence, node: node)
                .then {
                    let tx = Transaction(sourceAccount: pk,
                                         seqNum: $0,
                                         timeBounds: self.timeBounds,
                                         memo: self.memo ?? .MEMO_NONE,
                                         operations: self.operations)

                    p.signal(tx)
                }
                .error { _ in
                    p.signal(StellarError.missingSequence)
            }
        }

        return p
    }

    public func envelope(networkId: Network.Id) -> Promise<TransactionEnvelope> {
        let p = Promise<TransactionEnvelope>()

        build()
            .then { transaction in
                do {
                    var transactionEnvelope = TransactionEnvelope(tx: transaction)
                    try transactionEnvelope.sign(account: self.source, networkId: networkId)
                    p.signal(transactionEnvelope)
                }
                catch {
                    p.signal(error)
                }
            }
            .error { error in
                p.signal(error)
        }

        return p
    }
}
