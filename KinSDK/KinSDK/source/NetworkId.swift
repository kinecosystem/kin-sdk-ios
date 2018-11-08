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
     A network with a custom issuer and Stellar sidentifier.
     */
    case custom(issuer: String, stellarNetworkId: BCNetworkId)
}

extension NetworkId {
    public var stellarNetworkId: BCNetworkId {
        switch self {
        case .mainNet:
            return BCNetworkId("private testnet")
        case .testNet:
            return BCNetworkId("private testnet")
        case .playground:
            return BCNetworkId("Kin Playground Network ; June 2018")
        case .custom(_, let stellarNetworkId):
            return stellarNetworkId
        }
    }
}

extension NetworkId: CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        switch self {
        case .mainNet:
            return "main"
        case .testNet:
            return "test"
        case .playground:
            return "playground"
        default:
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
        default:
            return false
        }
    }
}
