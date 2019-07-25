//
//  AccountResponse.swift
//  KinSDK
//
//  Created by Corey Werner on 21/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

struct AccountResponse: Decodable {
    let keyPair: String
    let sequenceNumber: Int64
    let pagingToken: String
    let subentryCount: Int
    let thresholds: Thresholds
    let flags: Flags
    let balances: [Balance]
    let signers: [Signer]
    let links: Links
    let data: [String: String]

    enum CodingKeys: String, CodingKey {
        case keyPair = "account_id"
        case sequenceNumber = "sequence"
        case pagingToken = "paging_token"
        case subentryCount = "subentry_count"
        case thresholds
        case flags
        case balances
        case signers
        case links = "_links"
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let sequenceNumber = Int64(try container.decode(String.self, forKey: .sequenceNumber)) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.sequenceNumber], debugDescription: "sequence must be a string that can parse to an int"))
        }

        keyPair = try container.decode(String.self, forKey: .keyPair)
        self.sequenceNumber = sequenceNumber
        pagingToken = try container.decode(String.self, forKey: .pagingToken)
        subentryCount = try container.decode(Int.self, forKey: .subentryCount)
        thresholds = try container.decode(Thresholds.self, forKey: .thresholds)
        flags = try container.decode(Flags.self, forKey: .flags)
        balances = try container.decode([Balance].self, forKey: .balances)
        signers = try container.decode([Signer].self, forKey: .signers)
        links = try container.decode(Links.self, forKey: .links)
        data = try container.decode([String: String].self, forKey: .data)
    }
}

extension AccountResponse {
    struct Thresholds: Decodable, Equatable, Hashable {
        let lowThreshold: Int
        let medThreshold: Int
        let highThreshold: Int

        enum CodingKeys: String, CodingKey {
            case lowThreshold = "low_threshold"
            case medThreshold = "med_threshold"
            case highThreshold = "high_threshold"
        }
    }
}

extension AccountResponse {
    struct Flags: Decodable, Equatable, Hashable {
        let authRequired: Bool
        let authRevocable: Bool
        let authImmutable: Bool

        enum CodingKeys: String, CodingKey {
            case authRequired = "auth_required"
            case authRevocable = "auth_revocable"
            case authImmutable = "auth_immutable"
        }
    }
}

extension AccountResponse {
    struct Balance: Decodable, Equatable, Hashable {
        let assetType: String
        let balance: Decimal

        enum CodingKeys: String, CodingKey {
            case assetType = "asset_type"
            case balance
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            guard let balance = Decimal(string: try container.decode(String.self, forKey: .balance)) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath + [CodingKeys.balance], debugDescription: "balance must be a string that can parse to a decimal"))
            }

            assetType = try container.decode(String.self, forKey: .assetType)
            self.balance = balance
        }
    }
}

extension AccountResponse {
    struct Signer: Decodable, Equatable, Hashable {
        let accountId: String
        let weight: Int

        enum CodingKeys: String, CodingKey {
            case accountId = "public_key"
            case weight
        }
    }
}

extension AccountResponse {
    struct Links: Decodable {
        let effects: Link
        let offers: Link
        let operations: Link
        let `self`: Link
        let transactions: Link
    }
}
