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
public final class TxBuilder: TransactionBuilder {

}

// TODO: uncomment final after removing TxBuilder
public /*final*/ class TransactionBuilder {
    private var source: Account
    private var memo: Memo?
    private var fee: Stroop?
    private var timeBounds: TimeBounds?
    private var sequence: UInt64 = 0
    private var operations = [Operation]()
    private var opSigners = [Account]()

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

    public func add(signer: Account) -> TransactionBuilder {
        opSigners.append(signer)

        return self
    }

    // TODO: verify if this is the `build` function of Android
    public func tx() -> Promise<Transaction> {
        let p = Promise<Transaction>()

        guard let sourceKey = source.publicKey else {
            p.signal(StellarError.missingPublicKey)

            return p
        }

        let pk = PublicKey.PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: sourceKey)))

        if sequence > 0 {
            p.signal(Transaction(sourceAccount: pk,
                                 seqNum: sequence,
                                 timeBounds: nil,
                                 memo: memo ?? .MEMO_NONE,
                                 fee: fee,
                                 operations: operations))
        }
        else {
            Stellar.sequence(account: sourceKey, seqNum: sequence, node: node)
                .then {
                    let tx = Transaction(sourceAccount: pk,
                                         seqNum: $0,
                                         timeBounds: nil,
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

        tx()
            .then { tx in
                do {
                    p.signal(try self.sign(tx: tx, networkId: networkId))
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
    
    private func sign(tx: Transaction, networkId: Network.Id) throws -> TransactionEnvelope {
        var sigs = [DecoratedSignature]()

        let m = try tx.hash(networkId: networkId)

        var signatories = opSigners
        signatories.append(source)

        try signatories.forEach({ signer in
            try sigs.append({
                guard let sign = signer.sign else {
                    throw StellarError.missingSignClosure
                }

                guard let publicKey = signer.publicKey else {
                    throw StellarError.missingPublicKey
                }

                let hint = WrappedData4(BCKeyUtils.key(base32: publicKey).suffix(4))
                return try DecoratedSignature(hint: hint, signature: sign(Array(m)))
            }())
        })

        return TransactionEnvelope(tx: tx, signatures: sigs)
    }
}
