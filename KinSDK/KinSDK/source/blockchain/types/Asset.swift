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

extension AssetType: CustomStringConvertible {
    var description: String {
        return "native"
    }
}

public enum Asset {
    case native
}

extension Asset: XDRCodable {
    public init(from decoder: XDRDecoder) throws {
        self = .native
    }

    public func encode(to encoder: XDREncoder) throws {
        try encoder.encode(AssetType.native)
    }
}
