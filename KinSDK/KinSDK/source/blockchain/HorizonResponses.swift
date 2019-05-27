//
//  HorizonResponses.swift
//  StellarKit
//
//  Created by Kin Foundation.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation

struct HorizonError: Decodable {
    let type: URL
    let title: String
    let status: Int
    let detail: String
    let instance: String?
    let extras: Extras?

    struct Extras: Decodable {
        let resultXDR: String

        enum CodingKeys: String, CodingKey {
            case resultXDR = "result_xdr"
        }
    }
}

public struct NetworkParameters: Decodable {
    private let _links: Links
    private let _embedded: [String: [LedgerResponse]]

    public var baseFee: Quark {
        return _embedded["records"]!.first!.base_fee_in_stroops
    }
}

public struct AccountDetails: Decodable, CustomStringConvertible {
    public let id: String
    public let accountId: String
    public let sequence: String
    public let balances: [Balance]

    public var seqNum: UInt64 {
        return UInt64(sequence) ?? 0
    }

    public struct Balance: Decodable, CustomStringConvertible {
        public let balance: String
        public let assetType: String

        public var balanceNum: Kin {
            return Decimal(string: balance) ?? Decimal()
        }

        public var asset: Asset {
            return .native
        }

        public var description: String {
            return "balance: \(balance)"
        }

        enum CodingKeys: String, CodingKey {
            case balance
            case assetType = "asset_type"
        }
    }

    public var description: String {
        return """
        id: \(id)
        publicKey: \(accountId)
        sequence: \(sequence)
        balances: \(balances)
        """
    }

    enum CodingKeys: String, CodingKey {
        case id
        case accountId = "account_id"
        case sequence
        case balances
    }
}

struct TransactionResponse: Decodable {
    let hash: String
    let resultXDR: String

    enum CodingKeys: String, CodingKey {
        case hash
        case resultXDR = "result_xdr"
    }
}

struct LedgerResponse: Decodable {
    let _links: Links?
    let id: String
    let hash: String
    let base_fee_in_stroops: Quark
    let base_reserve_in_stroops: Quark
    let max_tx_set_size: Int
}

public struct AggregatedBalanceResponse: Decodable {
    let _links: Links
    public let publicAddress: String
    public let balance: Kin

    private enum RootKeys: String, CodingKey {
        case _links
        case _embedded
    }

    private enum EmbeddedKeys: String, CodingKey {
        case records
    }

    private enum AggregatedBalanceKeys: String, CodingKey {
        case accountId = "account_id"
        case balance = "aggregate_balance"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        let embeddedContainer = try container.nestedContainer(keyedBy: EmbeddedKeys.self, forKey: ._embedded)
        var aggregatedBalancesContainer = try embeddedContainer.nestedUnkeyedContainer(forKey: .records)
        let aggregatedBalanceContainer = try aggregatedBalancesContainer.nestedContainer(keyedBy: AggregatedBalanceKeys.self)

        self._links = try container.decode(Links.self, forKey: ._links)
        self.publicAddress = try aggregatedBalanceContainer.decode(String.self, forKey: .accountId)
        self.balance = try aggregatedBalanceContainer.decode(Kin.self, forKey: .balance)
    }
}

public struct ControlledAccountsResponse: Decodable {
    let _links: Links
    public let controlledAccounts: [ControlledAccount]

    private enum RootKeys: String, CodingKey {
        case _links
        case _embedded
    }

    private enum EmbeddedKeys: String, CodingKey {
        case records
    }

    private enum ControlledAccountKeys: String, CodingKey {
        case accountId = "account_id"
        case balance
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        let embeddedContainer = try container.nestedContainer(keyedBy: EmbeddedKeys.self, forKey: ._embedded)
        var controlledAccountsContainer = try embeddedContainer.nestedUnkeyedContainer(forKey: .records)
        var controlledAccounts: [ControlledAccount] = []

        while !controlledAccountsContainer.isAtEnd {
            let controlledAccountContainer = try controlledAccountsContainer.nestedContainer(keyedBy: ControlledAccountKeys.self)
            let publicAddress = try controlledAccountContainer.decode(String.self, forKey: .accountId)
            let balance = try controlledAccountContainer.decode(Kin.self, forKey: .balance)
            controlledAccounts.append(ControlledAccount(balance: balance, publicAddress: publicAddress))
        }

        self._links = try container.decode(Links.self, forKey: ._links)
        self.controlledAccounts = controlledAccounts
    }
}

public struct ControlledAccount: Decodable {
    public let balance: Kin
    public let publicAddress: String
}

struct Links: Decodable {
    let `self`: Link

    let next: Link?
    let prev: Link?

    let transactions: Link?
    let operations: Link?
    let payments: Link?
    let effects: Link?
}

struct Link: Decodable {
    let href: String
    let templated: Bool?
}
