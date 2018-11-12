//
//  NetworkId.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

/**
 `NetworkId` represents the block chain network to which `KinClient` will connect.
 */
public enum NetworkId {
    /**
     Kik's private Stellar production network.
     */
    case mainNet

    /**
     Kik's private Stellar test network.
     */
    case testNet

    /**
     Kik's private Stellar playground network.
     */
    case playground

    /**
     A network with a custom Stellar identifier.
     */
    case custom(stellarNetworkId: BCNetworkId)
}

extension NetworkId {
    private enum CodingKeys: String, CodingKey {
        case mainNet
        case testNet
        case playground
        case custom
    }

    public var stellarNetworkId: BCNetworkId {
        switch self {
        case .mainNet:
            return BCNetworkId("Public Global Kin Ecosystem Network ; June 2018")
        case .testNet:
            return BCNetworkId("private testnet")
        case .playground:
            return BCNetworkId("Kin Playground Network ; June 2018")
        case .custom(let stellarNetworkId):
            return stellarNetworkId
        }
    }
}

extension NetworkId: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let _ = try? container.decode(String.self, forKey: .mainNet) {
            self = .mainNet
        }
        else if let _ = try? container.decode(String.self, forKey: .testNet) {
            self = .testNet
        }
        else if let _ = try? container.decode(String.self, forKey: .playground) {
            self = .playground
        }
        else if let stellarNetworkId = try? container.decode(BCNetworkId.self, forKey: .custom) {
            self = .custom(stellarNetworkId: stellarNetworkId)
        }
        else {
            throw StellarError.dataDencodingFailed
        }
    }
}

extension NetworkId: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .mainNet:
            try container.encode(self.description, forKey: .mainNet)
        case .testNet:
            try container.encode(self.description, forKey: .testNet)
        case .playground:
            try container.encode(self.description, forKey: .playground)
        case .custom(let stellarNetworkId):
            try container.encode(stellarNetworkId, forKey: .custom)
        }
    }
}

extension NetworkId: CustomStringConvertible {
    private func networkId(description: String) -> NetworkId? {
        switch description {
        case NetworkId.mainNet.description:
            return .mainNet
        case NetworkId.testNet.description:
            return .testNet
        case NetworkId.playground.description:
            return .playground
        default:
            return nil
        }
    }

    /// :nodoc:
    public var description: String {
        switch self {
        case .mainNet:
            return "main"
        case .testNet:
            return "test"
        case .playground:
            return "playground"
        case .custom(_):
            return "custom network"
        }
    }
}

extension NetworkId: Equatable {
    public static func ==(lhs: NetworkId, rhs: NetworkId) -> Bool {
        switch lhs {
        case .mainNet:
            switch rhs {
            case .mainNet:
                return true
            default:
                return false
            }
        case .testNet:
            switch rhs {
            case .testNet:
                return true
            default:
                return false
            }
        case .playground:
            switch rhs {
            case .playground:
                return true
            default:
                return false
            }
        case .custom(_):
            return false
        }
    }
}

fileprivate struct CustomNetworkIdValues: Codable {
    let issuer: String
    let stellarNetworkId: BCNetworkId
}
