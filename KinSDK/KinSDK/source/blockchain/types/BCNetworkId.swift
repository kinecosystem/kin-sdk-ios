//
// BCNetworkId.swift
// KinSDK
//
// Created by Kin Foundation.
// Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation

public enum BCNetworkId {
    case test
    case main
    case custom(String)
}

extension BCNetworkId {
    private enum CodingKeys: String, CodingKey {
        case test
        case main
        case custom
    }
}

extension BCNetworkId: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let _ = try? container.decode(String.self, forKey: .test) {
            self = .test
        }
        else if let _ = try? container.decode(String.self, forKey: .main) {
            self = .main
        }
        else if let identifier = try? container.decode(String.self, forKey: .custom) {
            self = .custom(identifier)
        }
        else {
            throw StellarError.dataDencodingFailed
        }
    }
}

extension BCNetworkId: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .test:
            try container.encode(self.description, forKey: .test)
        case .main:
            try container.encode(self.description, forKey: .main)
        case .custom(let value):
            try container.encode(value, forKey: .custom)
        }
    }
}

extension BCNetworkId: CustomStringConvertible {
    public init(_ identifier: String) {
        switch identifier {
        case BCNetworkId.test.description:
            self = .test
        case BCNetworkId.main.description:
            self = .main
        default:
            self = .custom(identifier)
        }
    }

    public var description: String {
        switch self {
        case .test:
            return "Test SDF Network ; September 2015"
        case .main:
            return "Public Global Stellar Network ; September 2015"
        case .custom(let identifier):
            return identifier
        }
    }
}
