//
//  KinClient.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

/**
 `KinClient` is a factory class for managing an instance of `KinAccount`.
 */
public final class KinClient {
    /**
     Convenience initializer to instantiate a `KinClient` with a `ServiceProvider`.

     - parameter provider: The `ServiceProvider` instance that provides the `URL` and `Network`.
     - parameter appId: The `AppId` of the host application.
     */
    public convenience init(provider: ServiceProvider, appId: AppId) {
        self.init(with: provider.url, network: provider.network, appId: appId)
    }

    /**
     Instantiates a `KinClient` with a `URL` and a `Network`.

     - parameter nodeProviderUrl: The `URL` of the node this client will communicate to.
     - parameter network: The `Network` to be used.
     - parameter appId: The `AppId` of the host application.
     */
    public init(with nodeProviderUrl: URL, network: Network, appId: AppId) {
        self.node = Stellar.Node(baseURL: nodeProviderUrl, network: network)

        self.accounts = KinAccounts(node: node, appId: appId)

        self.network = network
    }

    public var url: URL {
        return node.baseURL
    }

    public private(set) var accounts: KinAccounts

    internal let node: Stellar.Node

    /**
     The `Network` of the network which this client communicates to.
     */
    public let network: Network

    /**
     Adds an account associated to this client, and returns it.

     - throws: If creating the account fails.
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

     - parameter passphrase: The passphrase to decrypt the secret key.

     - return: The imported account
     **/
    public func importAccount(_ jsonString: String,
                              passphrase: String) throws -> KinAccount {
        guard let data = jsonString.data(using: .utf8) else {
            throw KinError.internalInconsistency
        }

        let accountData = try JSONDecoder().decode(AccountData.self, from: data)

        try KeyStore.importAccount(accountData,
                                   passphrase: passphrase,
                                   newPassphrase: "")

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
     Cached minimum fee.
     */
    private var _minFee: Stroop?

    /**
     Get the minimum fee for sending a transaction.

     - Returns: The minimum fee needed to send a transaction.
     */
    public func minFee() -> Promise<Stroop> {
        let promise = Promise<Stroop>()

        if let minFee = _minFee {
            promise.signal(minFee)
        }
        else {
            Stellar.networkParameters(node: node)
                .then { [weak self] networkParameters in
                    self?._minFee = networkParameters.baseFee
                    promise.signal(networkParameters.baseFee)
                }
                .error { error in
                    promise.signal(error)
            }
        }

        return promise
    }
}
