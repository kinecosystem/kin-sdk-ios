//
//  KinClient.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

/**
 `KinClient` is a factory class for managing instances of `KinAccount`.
 */
public final class KinClient {
    /**
     Instantiates a `KinClient` with a `Network` and an `AppId`.

     - Parameter network: The `Network` to be used.
     - Parameter appId: The `AppId` of the host application.
     */
    public init(network: Network, appId: AppId) {
        Network.current = network

        self.accounts = KinAccounts(stellar: stellar, appId: appId)
    }

    let stellar = Stellar()

    /**
     The list of `KinAccount` objects this client is managing.
     */
    public private(set) var accounts: KinAccounts

    /**
     The `Network` of the network which this client communicates to.
     */
    public var network: Network {
        return Network.current
    }

    /**
     Adds an account associated to this client, and returns it.

     - Throws: `KinError.accountCreationFailed` if creating the account fails.

     - Returns: The newly added `KinAccount` which only exists locally.
     */
    public func addAccount() throws -> KinAccount {
        do {
            return try accounts.createAccount()
        }
        catch {
            throw KinError.accountCreationFailed(error)
        }
    }

    /**
     Deletes the account at the given index. This method is a no-op if there is no account at
     that index.

     If this is an action triggered by the user, make sure you let the him know that any funds owned
     by the account will be lost if it hasn't been backed up. See
     `exportKeyStore(passphrase:exportPassphrase:)`.

     - parameter index: The index of the account to delete.

     - throws: When deleting the account fails.
     */
    public func deleteAccount(at index: Int) throws {
        do {
            try accounts.deleteAccount(at: index)
        }
        catch {
            throw KinError.accountDeletionFailed(error)
        }
    }

    /**
     Import an account from a JSON-formatted string.

     - Parameter passphrase: The passphrase to decrypt the secret key.

     - Throws: `KinError.internalInconsistency` if the given `jsonString` could not be parsed or if the import does not work.

     - Returns: The imported account
     */
    public func importAccount(_ jsonString: String,
                              passphrase: String) throws -> KinAccount {
        guard let data = jsonString.data(using: .utf8) else {
            throw KinError.internalInconsistency
        }

        let accountData = try JSONDecoder().decode(StellarAccount.KeychainData.self, from: data)

        try KeyStore.importAccount(accountData, passphrase: passphrase)

        guard let account = accounts.last else {
            throw KinError.internalInconsistency
        }

        return account
    }

    /**
     Deletes the keystore.
     */
    public func deleteKeystore() {
        for _ in 0..<KeyStore.count() {
            KeyStore.remove(at: 0)
        }

        accounts.flushCache()
    }
    
    /**
     Get the minimum fee for sending a transaction.

     - Returns: The minimum fee needed to send a transaction.
     */
    public func minFee() -> Promise<Quark> {
        return stellar.minFee()
    }
}

// MARK: - Deprecated

extension KinClient {
    /**
     The `URL` of the node this client communicates to.
     */
    @available(*, deprecated, renamed: "network.url")
    public var url: URL {
        return Network.current.url
    }
}
