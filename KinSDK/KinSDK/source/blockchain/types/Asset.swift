//
//  Asset.swift
//  StellarKit
//
//  Created by Kin Foundation
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation

struct AssetType {
    static let native: Int32 = 0
}

public enum Asset: XDRCodable {
    case native

    public var assetCode: String {
        return "native"
    }

    public init(from decoder: XDRDecoder) throws {
        self = .native
    }

    public func encode(to encoder: XDREncoder) throws {
        try encoder.encode(AssetType.native)
    }
}
