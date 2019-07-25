//
//  AccountData.swift
//  KinSDK
//
//  Created by Corey Werner on 21/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

public struct AccountData: Equatable, Hashable {
    let publicAddress: String
    let sequenceNumber: Int64
    let pagingToken: String
    let subentryCount: Int
    let thresholds: AccountResponse.Thresholds
    let flags: AccountResponse.Flags
    let balances: [AccountResponse.Balance]
    let signers: [AccountResponse.Signer]
    let data: [String: String]
}
