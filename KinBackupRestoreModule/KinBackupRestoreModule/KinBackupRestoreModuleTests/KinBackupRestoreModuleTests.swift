//
//  KinBackupRestoreModuleTests.swift
//  KinBackupRestoreModuleTests
//
//  Created by Corey Werner on 03/02/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinBackupRestoreModule
@testable import KinSDK

class KinBackupRestoreModuleTests: XCTestCase {
    // MARK: Convenience

    var _client: KinClient?
    var client: KinClient {
        guard let client = _client else {
            XCTAssertTrue(false, "Client doesn't exist")
            fatalError()
        }
        return client
    }

    // MARK: Lifecycle

    override func setUp() {
        let url = URL(string: "https://horizon-testnet.kininfrastructure.com")!
        let appId = try! AppId("tes5")
        _client = KinClient(with: url, network: .testNet, appId: appId)
    }

    override func tearDown() {
        _client?.deleteKeystore()
    }

    // MARK: Tests

    func testBackupAndRestoreAccount() {
        let passphrase = "A random passphrase"
        let account: KinAccount

        do {
            account = try client.addAccount()
        }
        catch {
            XCTAssertTrue(false, error.localizedDescription)
            return
        }

        let address = account.publicAddress
        let string: String
        
        do {
            string = try account.export(passphrase: passphrase)
        }
        catch {
            XCTAssertTrue(false, error.localizedDescription)
            return
        }

        guard let qrImage = QR.encode(string: string) else {
            XCTAssertTrue(false, "Could not encode QR string")
            return
        }

        do {
            try client.deleteAccount(at: client.accounts.count - 1)
        }
        catch {
            XCTAssertTrue(false, error.localizedDescription)
            return
        }

        guard let qrString = QR.decode(image: qrImage) else {
            XCTAssertTrue(false, "Could not decode QR image")
            return
        }

        let importedAccount: KinAccount

        do {
            importedAccount = try client.importAccount(qrString, passphrase: passphrase)
        }
        catch {
            XCTAssertTrue(false, error.localizedDescription)
            return
        }

        XCTAssertTrue(address == importedAccount.publicAddress, "Public addresses do not match")
    }
}
