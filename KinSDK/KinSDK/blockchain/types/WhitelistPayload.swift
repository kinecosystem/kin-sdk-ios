//
//  WhitelistPayload.swift
//  KinSDK
//
//  Created by Corey Werner on 01/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

/**
 `WhitelistPayload` wraps a `Transaction.Envelope` and the `Network.Id`.
 */
public struct WhitelistPayload {

    /**
     The `Transaction.Envelope`.
     */
    public let transactionEnvelope: Transaction.Envelope

    /**
     The `Network.Id`.
     */
    public let networkId: Network.Id

    /**
     Initializes the `WhitelistEnvelope`.

     - Parameter transactionEnvelope:
     - Parameter networkId:
     */
    public init(transactionEnvelope: Transaction.Envelope, networkId: Network.Id) {
        self.transactionEnvelope = transactionEnvelope
        self.networkId = networkId
    }
}

extension WhitelistPayload {
    enum CodingKeys: String, CodingKey {
        case transactionEnvelope = "tx_envelope"
        case networkId = "network_id"
    }
}

extension WhitelistPayload: Decodable {
    /**
     Initializes the `WhitelistEnvelope` with a Decoder.

     - Parameter from: The `Decoder` object to decode from.
     */
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let transactionEnvelopeData = try values.decode(Data.self, forKey: .transactionEnvelope)
        transactionEnvelope = try XDRDecoder.decode(Transaction.Envelope.self, data: transactionEnvelopeData)

        networkId = try values.decode(Network.Id.self, forKey: .networkId)
    }
}

extension WhitelistPayload: Encodable {
    /**
     Encode the `WhitelistEnvelope` into the given Encoder.

     - Parameter to: The `Encoder`.

     - Throws:
     */
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let transactionEnvelopeData = try XDREncoder.encode(transactionEnvelope)
        try container.encode(transactionEnvelopeData, forKey: .transactionEnvelope)

        try container.encode(networkId, forKey: .networkId)
    }
}

@available(*, deprecated, renamed: "WhitelistPayload")
public struct WhitelistEnvelope {}
