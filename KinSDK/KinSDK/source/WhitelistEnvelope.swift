//
// WhitelistEnvelope.swift
// KinSDK
//
// Created by Kin Foundation.
// Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation

public struct WhitelistEnvelope {
    public let transactionEnvelope: TransactionEnvelope
    public let networkId: Network.Id

    public init(transactionEnvelope: TransactionEnvelope, networkId: Network.Id) {
        self.transactionEnvelope = transactionEnvelope
        self.networkId = networkId
    }
}

extension WhitelistEnvelope {
    enum CodingKeys: String, CodingKey {
        case transactionEnvelope = "envelope"
        case networkId = "network_id"
    }
}

extension WhitelistEnvelope: Decodable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let transactionEnvelopeData = try values.decode(Data.self, forKey: .transactionEnvelope)
        transactionEnvelope = try XDRDecoder.decode(TransactionEnvelope.self, data: transactionEnvelopeData)

        networkId = try values.decode(Network.Id.self, forKey: .networkId)
    }
}

extension WhitelistEnvelope: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let transactionEnvelopeData = try XDREncoder.encode(transactionEnvelope)
        try container.encode(transactionEnvelopeData, forKey: .transactionEnvelope)

        try container.encode(networkId, forKey: .networkId)
    }
}
