//
//  KeyStoreTests.swift
//  StellarKitTests
//
//  Created by Kin Foundation
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK

class KeyStoreTests: XCTestCase {
    var account1: StellarAccount!
    var account2: StellarAccount!
    var issuer: StellarAccount!

    override func setUp() {
        super.setUp()

        KeyStore.removeAll()

        if KeyStore.count() > 0 {
            XCTAssertTrue(false, "Unable to clear existing accounts!")
        }

        self.account1 = try? KeyStore.newAccount()
        self.account2 = try? KeyStore.newAccount()

        if account1 == nil || account2 == nil {
            XCTAssertTrue(false, "Unable to create account(s)!")
        }

        issuer = try? KeyStore.importSecretSeed("SCML43HASLG5IIN34KCJLDQ6LPWYQ3HIROP5CRBHVC46YRMJ6QLOYQJS")

        if issuer == nil {
            XCTAssertTrue(false, "Unable to import issuer account!")
        }
    }

    override func tearDown() {
        super.tearDown()

        KeyStore.removeAll()
    }

    func test_extra_data() {
        try? KeyStore.set(extra: Data([1, 2, 4]), for: KeyStore.account(at: 0)!)
        let a1 = KeyStore.account(at: 0)
        try XCTAssertEqual(Data([1, 2, 4]), a1?.extra())
    }

    func test_remove() {
        let account_pkey = account1.publicKey

        KeyStore.remove(at: 1)

        let account_0_pkey = KeyStore.account(at: 0)!.publicKey!

        XCTAssertEqual(account_pkey, account_0_pkey, "It looks like the wrong account was removed!")
    }

    func test_removing_middle_account_fills_hole() {
        let issuer_pkey = issuer!.publicKey!

        XCTAssertNotEqual(issuer_pkey, KeyStore.account(at: 1)!.publicKey!,
                          "Issuer should not be at index 1!")

        KeyStore.remove(at: 1)

        XCTAssertEqual(issuer_pkey, KeyStore.account(at: 1)!.publicKey!,
                       "Issuer should be at index 1!")
    }

    func test_export_with_different_passphrase() {
        let store = KeyStore.exportAccount(account: account1, passphrase: "new phrase")

        XCTAssertNotNil(store)
    }

    func test_export_with_same_passphrase() {
        let store = KeyStore.exportAccount(account: account1, passphrase: "")

        XCTAssertNotNil(store)
    }

    func test_import_with_different_passphrase() {
        let count = KeyStore.count()

        let store = KeyStore.exportAccount(account: account1, passphrase: "new phrase")

        try? KeyStore.importAccount(store!, passphrase: "new phrase")

        XCTAssert(KeyStore.count() == count + 1)
    }

    func test_import_with_same_passphrase() {
        let count = KeyStore.count()

        let store = KeyStore.exportAccount(account: account1, passphrase: "")

        try? KeyStore.importAccount(store!, passphrase: "")

        XCTAssert(KeyStore.count() == count + 1)
    }

    func test_import_with_different_wrong_passphrase() {
        let store = KeyStore.exportAccount(account: account1, passphrase: "new phrase")

        do {
            try KeyStore.importAccount(store!, passphrase: "wrong phrase")

            XCTFail("Expected exception.")
        }
        catch {}
    }

    func test_import_with_same_wrong_passphrase() {
        let store = KeyStore.exportAccount(account: account1, passphrase: "")

        do {
            try KeyStore.importAccount(store!, passphrase: "wrong phrase")

            XCTFail("Expected exception.")
        }
        catch {}
    }

    func test_seed_import() {
        let count = KeyStore.count()

        let account = try? KeyStore.importSecretSeed("SCML43HASLG5IIN34KCJLDQ6LPWYQ3HIROP5CRBHVC46YRMJ6QLOYQJS")

        XCTAssertNotNil(account)

        let storedAccount = KeyStore.account(at: count)

        XCTAssertEqual(account!.publicKey!, storedAccount!.publicKey!)
    }

}
