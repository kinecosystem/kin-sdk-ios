//
//  Transaction.swift
//  StellarKit
//
//  Created by Kin Foundation
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation

struct MemoType {
    static let MEMO_NONE: Int32 = 0
    static let MEMO_TEXT: Int32 = 1
    static let MEMO_ID: Int32 = 2
    static let MEMO_HASH: Int32 = 3
    static let MEMO_RETURN: Int32 = 4
}

/**
 `Memo` is a encodable data type used to attach arbitrary details `Transaction` such as an order number.
 */
public enum Memo: XDRCodable {
    case MEMO_NONE
    case MEMO_TEXT (String)
    case MEMO_ID (UInt64)
    case MEMO_HASH (Data)
    case MEMO_RETURN (Data)

    /**
     The `String` representation of the `Memo`, either text when the `Memo` is of type text, or the hash value for other data types.
     */
    public var text: String? {
        if case let .MEMO_TEXT(text) = self {
            return text
        }

        if case let .MEMO_HASH(data) = self, let s = String(data: data, encoding: .utf8) {
            return s
        }

        return nil
    }

    /**
     The `Data` representation of the `Memo`.
     */
    public var data: Data? {
        if case let .MEMO_HASH(data) = self {
            return data
        }

        return nil
    }

    /**
     Initializer to instantiate a `Memo` of the text type with a `String`

     - Parameter string: the text string.

     - Throws: `StellarError.memoTooLong` if the `String` provided is longer than 28 characters.
     */
    public init(_ string: String) throws {
        guard string.utf8.count <= 28 else {
            throw StellarError.memoTooLong(string)
        }

        self = .MEMO_TEXT(string)
    }

    /**
     Initializer to instantiate a `Memo` of the data type with a `Data`.

     - Parameter data: the `Data` object.

     - Throws: `StellarError.memoTooLong` if the `Data` provided is longer than 32.
     */
    public init(_ data: Data) throws {
        guard data.count <= 32 else {
            throw StellarError.memoTooLong(data)
        }

        self = .MEMO_HASH(data)
    }

    private func discriminant() -> Int32 {
        switch self {
        case .MEMO_NONE: return MemoType.MEMO_NONE
        case .MEMO_TEXT: return MemoType.MEMO_TEXT
        case .MEMO_ID: return MemoType.MEMO_ID
        case .MEMO_HASH: return MemoType.MEMO_HASH
        case .MEMO_RETURN: return MemoType.MEMO_RETURN
        }
    }

    /**
     Initializer to instantiate a `Memo` of the data type corresponding to the `XDRDecoder`.

     - Parameter from: the `XDRDecoder` object.

     - Throws:
     */
    public init(from decoder: XDRDecoder) throws {
        let discriminant = try decoder.decode(Int32.self)

        switch discriminant {
        case MemoType.MEMO_NONE:
            self = .MEMO_NONE
        case MemoType.MEMO_ID:
            self = .MEMO_ID(try decoder.decode(UInt64.self))
        case MemoType.MEMO_TEXT:
            self = .MEMO_TEXT(try decoder.decode(String.self))
        case MemoType.MEMO_HASH:
            self = .MEMO_HASH(try decoder.decode(WrappedData32.self).wrapped)
        default:
            self = .MEMO_NONE
        }
    }

    public func encode(to encoder: XDREncoder) throws {
        try encoder.encode(discriminant())

        switch self {
        case .MEMO_NONE: break
        case .MEMO_TEXT (let text): try encoder.encode(text)
        case .MEMO_ID (let id): try encoder.encode(id)
        case .MEMO_HASH (let hash): try encoder.encode(WrappedData32(hash))
        case .MEMO_RETURN (let hash): try encoder.encode(WrappedData32(hash))
        }
    }
}

public struct TimeBounds: XDRCodable, XDREncodableStruct {
    public init(from decoder: XDRDecoder) throws {
        minTime = try decoder.decode(UInt64.self)
        maxTime = try decoder.decode(UInt64.self)
    }

    let minTime: UInt64
    let maxTime: UInt64
}

struct EnvelopeType {
    static let ENVELOPE_TYPE_SCP: Int32 = 1
    static let ENVELOPE_TYPE_TX: Int32 = 2
    static let ENVELOPE_TYPE_AUTH: Int32 = 3
}

struct TransactionSignaturePayload: XDREncodableStruct {
    let networkId: WrappedData32
    let taggedTransaction: TaggedTransaction

    enum TaggedTransaction: XDREncodable {
        case ENVELOPE_TYPE_TX (Transaction)

        private func discriminant() -> Int32 {
            switch self {
            case .ENVELOPE_TYPE_TX: return EnvelopeType.ENVELOPE_TYPE_TX
            }
        }

        func encode(to encoder: XDREncoder) throws {
            try encoder.encode(discriminant())

            switch self {
            case .ENVELOPE_TYPE_TX (let tx): try encoder.encode(tx)
            }
        }
    }
}

public struct DecoratedSignature: XDRCodable, XDREncodableStruct {
    let hint: WrappedData4;
    let signature: [UInt8]

    public init(from decoder: XDRDecoder) throws {
        hint = try decoder.decode(WrappedData4.self)
        signature = try decoder.decodeArray(UInt8.self)
    }

    init(hint: WrappedData4, signature: [UInt8]) {
        self.hint = hint
        self.signature = signature
    }
}

/**
 A `Transaction` represents a transaction that modifies the ledger in the blockchain network.
 A Kin `Transaction` is used to send payments.
 */
// TODO: remove public
public struct Transaction: XDRCodable {
    public let fee: Quark
    let sourceAccount: PublicKey
    public let seqNum: UInt64 // TODO: sequenceNumber
    public let operations: [Operation]
    public let memo: Memo
    public let timeBounds: TimeBounds?

    public var signatures: [DecoratedSignature] = []
    private let reserved: Int32 = 0

    /**
     Maximum length of a `Memo` object.
     */
    public static let MaxMemoLength = 28

    /**
     Initialize a `Transaction`.

     - SeeAlso: [Transactions in the Stellar network](https://www.stellar.org/developers/guides/concepts/transactions.html).

     - Parameter sourceAccount: The public address of the source account.
     - Parameter seqNum: Each transaction has a sequence number.
     - Parameter timeBounds: optional UNIX timestamp (in seconds) of a lower and upper bound of when this transaction will be valid. If a transaction is submitted too early or too late, it will fail to make it into the transaction set. maxTime equal 0 means that it’s not set.
     - Parameter memo: optional extra information such as an order number.
     - Parameter fee: Each transaction sets a fee in `Quark` that is paid by the source account.
     - Parameter operations: Transactions contain an arbitrary list of operations inside them. Typically there is just 1 operation.
     */
    public init(sourceAccount: String, // TODO: sourcePublicAddress
                seqNum: UInt64,
                timeBounds: TimeBounds?,
                memo: Memo,
                fee: Quark? = nil,
                operations: [Operation]) {
        self.init(sourceAccount: .PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: sourceAccount))),
                  seqNum: seqNum,
                  timeBounds: timeBounds,
                  memo: memo,
                  fee: fee,
                  operations: operations)
    }

    init(sourceAccount: PublicKey,
         seqNum: UInt64,
         timeBounds: TimeBounds?,
         memo: Memo,
         fee: Quark? = nil,
         operations: [Operation]) {
        self.sourceAccount = sourceAccount
        self.seqNum = seqNum
        self.timeBounds = timeBounds
        self.memo = memo
        self.operations = operations

        self.fee = fee ?? UInt32(100 * operations.count)
    }

    /**
     Initializes a `Transaction` from a `XDRDecoder`.

     - Parameter from: The `XDRDecoder` containing all the transaction information.

     - Throws:
     */
    public init(from decoder: XDRDecoder) throws {
        sourceAccount = try decoder.decode(PublicKey.self)
        fee = try decoder.decode(UInt32.self)
        seqNum = try decoder.decode(UInt64.self)
        timeBounds = try decoder.decodeArray(TimeBounds.self).first
        memo = try decoder.decode(Memo.self)
        operations = try decoder.decodeArray(Operation.self)
        _ = try decoder.decode(Int32.self)
    }

    /**
     Encodes this `Transaction` to the given XDREncoder.

     - Parameter to: the `XDREncoder` to encode to.

     - Throws:
     */
    public func encode(to encoder: XDREncoder) throws {
        try encoder.encode(sourceAccount)
        try encoder.encode(fee)
        try encoder.encode(seqNum)
        try encoder.encodeOptional(timeBounds)
        try encoder.encode(memo)
        try encoder.encode(operations)
        try encoder.encode(reserved)
    }

    /**
     Hash representing the signature of the payload of the `Transaction`.

     - Returns: the hash `Data`

     - Throws: `StellarError.dataEncodingFailed` if the network id could not be encoded.
     */
    public func hash() throws -> Data {
        guard let data = Network.current.id.data(using: .utf8)?.sha256 else {
            throw StellarError.dataEncodingFailed
        }

        let payload = TransactionSignaturePayload(networkId: WD32(data), taggedTransaction: .ENVELOPE_TYPE_TX(self))

        return try XDREncoder.encode(payload).sha256
    }

    public mutating func sign(account: StellarAccount) throws {
        let message = Array(try hash())
        let hint = WrappedData4(BCKeyUtils.key(base32: account.publicAddress).suffix(4))
        let signature = try account.sign(message: message)

        signatures.append(DecoratedSignature(hint: hint, signature: signature))
    }

    public mutating func sign(kinAccount: KinAccount) throws {
        try sign(account: kinAccount.stellarAccount)
    }

    var memoString: String? {
        if case let Memo.MEMO_TEXT(text) = memo {
            return text
        }

        return nil
    }

    public func envelope() -> Envelope {
        return Envelope(transaction: self, signatures: signatures)
    }

    public func wrapper() -> BaseTransaction {
        return TransactionFactory.wrapping(transaction: self, sourcePublicAddress: sourceAccount.publicKey)
    }
}

extension Transaction {
    public struct Envelope: XDRCodable, XDREncodableStruct {
        public let tx: Transaction
        public let signatures: [DecoratedSignature]

        /**
         Initializes a `Transaction.Envelope` from an `XDRDecoder`.

         - Parameter from: the `XDRDecoder` to decode.

         - Throws:
         */
        public init(from decoder: XDRDecoder) throws {
            tx = try decoder.decode(Transaction.self)
            signatures = try decoder.decodeArray(DecoratedSignature.self)
        }

        init(transaction: Transaction, signatures: [DecoratedSignature] = []) {
            self.tx = transaction
            self.signatures = signatures
        }

        public func wrappedTransaction() -> BaseTransaction {
            return TransactionFactory.wrapping(transaction: tx, sourcePublicAddress: tx.sourceAccount.publicKey)
        }
    }
}

@available(*, deprecated, renamed: "Transaction.Envelope")
public struct TransactionEnvelope {}
