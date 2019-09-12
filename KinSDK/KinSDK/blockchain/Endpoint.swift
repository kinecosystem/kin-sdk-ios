//
//  Endpoint.swift
//  StellarKit
//
//  Created by Kin Foundation.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation

protocol EndpointProtocol {
    var base: URL { get }
    var url: URL { get }
    var params: [String: Any] { get }
}

extension EndpointProtocol {
    var url: URL {
        var p: String = params.isEmpty ? "" : "?"
        p += params.map({ "\($0.key)=\($0.value)" }).joined(separator: "&")

        return URL(string: base.absoluteString + p)!
    }
}

struct Endpoint: EndpointProtocol {
    let base: URL
    let params: [String: Any]

    init(_ base: URL = Network.current.url) {
        self.base = base
        params = [:]
    }
}

struct AccountEndpoint: EndpointProtocol {
    let base: URL
    let params: [String: Any]
}

struct PaymentsEndpoint: EndpointProtocol {
    let base: URL
    let params: [String: Any]
}

struct TransactionsEndpoint: EndpointProtocol {
    let base: URL
    let params: [String: Any]
}

struct LedgersEndpoint: EndpointProtocol {
    let base: URL
    let params: [String: Any]

    enum Order: String {
        case ascending = "asc"
        case descending = "desc"
    }
}

struct AggregatedBalanceEndpoint: EndpointProtocol {
    let base: URL
    let params: [String: Any]
}

struct ControlledAccountsEndpoint: EndpointProtocol {
    let base: URL
    let params: [String: Any]
}

struct CursorEndpoint: EndpointProtocol {
    let base: URL
    let params: [String: Any]
}

extension Endpoint {
    func account(_ account: String?) -> AccountEndpoint {
        let b = account != nil
            ? base.appendingPathComponent("accounts").appendingPathComponent(account!, isDirectory: false)
            : base

        return AccountEndpoint(base: b, params: params)
    }

    func payments() -> PaymentsEndpoint {
        return KinSDK.payments(url: base, params: params)
    }

    func transactions() -> TransactionsEndpoint {
        return KinSDK.transactions(url: base, params: params)
    }

    func ledgers() -> LedgersEndpoint {
        return KinSDK.ledgders(url: base, params: params)
    }
}

extension AccountEndpoint {
    func payments() -> PaymentsEndpoint {
        return KinSDK.payments(url: base, params: params)
    }

    func transactions() -> TransactionsEndpoint {
        return KinSDK.transactions(url: base, params: params)
    }

    func aggregatedBalance() -> AggregatedBalanceEndpoint {
        return KinSDK.aggregatedBalance(url: base, params: params)
    }

    func controlledAccounts() -> ControlledAccountsEndpoint {
        return KinSDK.controlledAccounts(url: base, params: params)
    }
}

extension PaymentsEndpoint {
    func cursor(_ cursor: String?) -> CursorEndpoint {
        return KinSDK.cursor(url: base, cursor: cursor)
    }
}

extension TransactionsEndpoint {
    func cursor(_ cursor: String?) -> CursorEndpoint {
        return KinSDK.cursor(url: base, cursor: cursor)
    }
}

extension LedgersEndpoint {
    func order(_ order: Order) -> LedgersEndpoint {
        var p = params
        p["order"] = order.rawValue

        return LedgersEndpoint(base: base, params: p)
    }

    func limit(_ limit: Int) -> LedgersEndpoint {
        var p = params
        p["limit"] = limit

        return LedgersEndpoint(base: base, params: p)
    }
}

extension AggregatedBalanceEndpoint {

}

extension ControlledAccountsEndpoint {

}

//MARK: -

private func payments(url: URL, params: [String: Any]) -> PaymentsEndpoint {
    return PaymentsEndpoint(base: url.appendingPathComponent("payments"), params: [:])
}

private func transactions(url: URL, params: [String: Any]) -> TransactionsEndpoint {
    return TransactionsEndpoint(base: url.appendingPathComponent("transactions"), params: [:])
}

private func ledgders(url: URL, params: [String: Any]) -> LedgersEndpoint {
    return LedgersEndpoint(base: url.appendingPathComponent("ledgers"), params: [:])
}

private func aggregatedBalance(url: URL, params: [String: Any]) -> AggregatedBalanceEndpoint {
    return AggregatedBalanceEndpoint(base: url.appendingPathComponent("aggregate_balance"), params: [:])
}

private func controlledAccounts(url: URL, params: [String: Any]) -> ControlledAccountsEndpoint {
    return ControlledAccountsEndpoint(base: url.appendingPathComponent("controlled_accounts"), params: [:])
}

private func cursor(url: URL, cursor: String?) -> CursorEndpoint {
    if let cursor = cursor {
        return CursorEndpoint(base: URL(string: url.absoluteString + "?cursor=\(cursor)")!, params: [:])
    }

    return CursorEndpoint(base: url, params: [:])
}

private func parameterFixup(url: URL, parameter: String) -> String {
    if url.absoluteString.contains("?") && parameter.first == "?" {
        return String(parameter.suffix(parameter.count - 1))
    }

    return parameter
}
