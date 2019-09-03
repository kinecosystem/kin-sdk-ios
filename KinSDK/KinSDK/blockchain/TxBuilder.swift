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
    private var sourcePublicAddress: String?
    private var memo: Memo?
    private var fee: Quark?
    private var timeBounds: TimeBounds?
    private var sequence: UInt64 = 0
    private var operations = [Operation]()

    init(sourcePublicAddress: String?) {
        self.sourcePublicAddress = sourcePublicAddress
    }

    @discardableResult
    public func set(memo: Memo) -> TransactionBuilder {
        self.memo = memo

        return self
    }

    @discardableResult
    public func set(fee: Quark) -> TransactionBuilder {
        self.fee = fee

        return self
    }

    @discardableResult
    public func set(timeBounds: TimeBounds) -> TransactionBuilder {
        self.timeBounds = timeBounds

        return self
    }

    @discardableResult
    public func set(sequence: UInt64) -> TransactionBuilder {
        self.sequence = sequence

        return self
    }

    @discardableResult
    public func add(operation: Operation) -> TransactionBuilder {
        operations.append(operation)

        return self
    }

    @discardableResult
    public func add(operations: [Operation]) -> TransactionBuilder {
        self.operations += operations

        return self
    }

    public func build() -> Promise<BaseTransaction> {
        let p = Promise<BaseTransaction>()

        guard let sourcePublicAddress = sourcePublicAddress else {
            p.signal(StellarError.missingPublicKey)

            return p
        }

        let pk = PublicKey.PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: sourcePublicAddress)))

        if sequence > 0 {
            let transaction = Transaction(sourceAccount: pk,
                                          seqNum: sequence,
                                          timeBounds: timeBounds,
                                          memo: memo ?? .MEMO_NONE,
                                          fee: fee,
                                          operations: operations)



            p.signal(transaction.wrapper())
        }
        else {
            Stellar.sequence(account: sourcePublicAddress, seqNum: sequence)
                .then { sequenceNumber in
                    let transaction = Transaction(sourceAccount: pk,
                                                  seqNum: sequenceNumber,
                                                  timeBounds: self.timeBounds,
                                                  memo: self.memo ?? .MEMO_NONE,
                                                  operations: self.operations)

                    p.signal(transaction.wrapper())
                }
                .error { _ in
                    p.signal(StellarError.missingSequence)
            }
        }

        return p
    }
}

// MARK: - Deprecated

extension TransactionBuilder {
    @available(*, deprecated, renamed: "build")
    public func tx() -> Promise<BaseTransaction> {
        return build()
    }
}
