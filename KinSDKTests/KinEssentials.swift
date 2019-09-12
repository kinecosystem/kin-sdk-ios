//
//  KinEssentials.swift
//  KinSDKTests
//
//  Created by Corey Werner on 10/09/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

@testable import KinSDK

/**
 This class helps with convenience and speed. Every `KinAccount` that's created can take ~10
 seconds. Using central shared accounts will significantly reduce the testing time.
 */
// TODO: rename to TestSetup
class KinEssentials {
    static let shared = KinEssentials()

    let client: KinClient
    let account0: KinAccount
    let account1: KinAccount

    init() {
        client = KinClientTests.createKinClient()
        account0 = KinAccountTests.createAccount(kinClient: client, amount: 999999)
        account1 = KinAccountTests.createAccount(kinClient: client, amount: 999999)
    }

    func deleteKeystore() {
        client.deleteKeystore()
    }
}
