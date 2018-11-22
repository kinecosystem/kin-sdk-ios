![Kin iOS](.github/kin_ios.png)

#  KinSDK

A library for using Kin.

## Installation

The SDK can not be installed currently. This is a work in progress.

## API Usage

The SDK exposes two classes, `KinClient` and `KinAccount`.

### KinClient
`KinClient` stores the configuration for the network, and is responsible for managing accounts.

```swift
let kinClient = KinClient(with: URL, networkId: NetworkId, appId: AppId)
```

##### Account Management

```swift
func addAccount() throws -> KinAccount

func deleteAccount(at index: Int) throws

func importAccount(_ jsonString: String, passphrase: String) throws -> KinAccount

var accounts: KinAccounts
```

---

### KinAccount

Before an account can be used on the configured network, it must be funded with the native network currency. This step must be performed by a service, and is outside the scope of this SDK.

##### KIN

To retrieve the account's current balance:

```swift
func balance(completion: @escaping BalanceCompletion)
```

To obtain a watcher object which will emit an event whenever the account's balance changes. See the Sample App for an example.

```swift
func watchBalance(_ balance: Kin?) throws -> BalanceWatch
```

To send KIN to another user, first generate a transaction.

```swift
func generateTransaction(to recipient: String, 
                         kin: Kin, 
                         memo: String?, 
                         completion: @escaping GenerateTransactionCompletion)
```

> The `memo` field can contain a string up to 28 characters in length. A typical usage is to include an order# that a service can use to verify payment.

Pass the returned `TransactionEnvelope` to the `WhitelistEnvelope`.

```swift
init(transactionEnvelope: TransactionEnvelope, networkId: Network.Id)
```

The `WhitelistEnvelope` should be passed to a server for signing. The server response should be a  `TransactionEnvelope` with a second signature, which can then be sent.

```swift
func sendTransaction(_ transactionEnvelope: TransactionEnvelope, 
                     completion: @escaping SendTransactionCompletion)
```

---

##### Miscellaneous

```swift
var publicAddress: String { get }
```

The account's address on the network. This is the identifier used to specify the destination for a payment, or to request account creation from a service.

```swift
func status(completion: @escaping (AccountStatus?, Error?) -> Void)
```

Creating an account is done by an external service. To obtain the current status of the account, call the above API.


#### Other Methods

Both `KinClient` and `KinAccount` have other methods which should prove useful. Specifically, `KinAccount` has alternative methods for many operations that are either synchronous, or return a Promise, instead of using a completion handler.

## Error handling

`KinSDK` wraps errors in an operation-specific error for each method of `KinAccount`.  The underlying error is the actual cause of failure.

### Common errors

`StellarError.missingAccount`: The account does not exist on the Stellar network. You must create the account by issuing a `CREATE_ACCOUNT` operation with `KinAccount.publicAddress` as the destination. This is done using an app-specific service, and is outside the scope of this SDK.

`StellarError.missingBalance`: For an account to receive KIN, it must trust the KIN Issuer. Call `KinAccount.activate()` to perform this operation.

## Contributing

Please review our [CONTRIBUTING.md](CONTRIBUTING.md) guide before opening issues and pull requests.

## License

This repository is licensed under the [MIT license](LICENSE.md).
