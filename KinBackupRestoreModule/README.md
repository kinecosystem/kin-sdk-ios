# Backup and Restore Standalone Module

This module is an optional way to back up and/or restore your account.
The module wraps the Kin SDK iOS import and export functionalities with a UI that includes two flows - backup and restore.
The UI uses a password to create a QR code, which is then used to back up the account and to restore it.

It is implemented as an iOS framework that can be incorporated into your code.
This framework is dependent on the kin-sdk framework, and we assume that whoever needs to use it is already familiar with the kin-sdk framework.  
For more details on Kin SDK, go to [kin-sdk on github](https://github.com/kinecosystem/kin-sdk-ios) and/or to our docs in the website - [kin-sdk docs](https://kinecosystem.github.io/kin-website-docs/docs/documentation/ios-sdk).

## Installation

The `KinBackupRestoreModule` for iOS is implemented as an iOS framework.
It can be included in your project with CocoaPods.

### CocoaPods

Add the following to your `Podfile`.

```
pod 'KinBackupRestoreModule'
```

For the latest release version, go to [https://github.com/kinecosystem/kin-sdk-ios/releases](https://github.com/kinecosystem/kin-sdk-ios/releases).

See the main repository at [github.com/kinecosystem/kin-sdk-ios](https://github.com/kinecosystem/kin-sdk-ios).


## Overview

Launching the Backup and Restore flows requires the following steps:

1. Creating the Backup and Restore Manager
2. Adding protocol stubs
3. Backup or Restore

### Step 1 - Creating the Backup and Restore Manager

You need to create a `KinBackupRestoreManager` object and set its `delegate`.

###### Example of how to create this object:

```swift
let backupRestoreManager = KinBackupRestoreManager()
backupRestoreManager.delegate = self
```

### Step 2 - Adding protocol stubs

- `didComplete` is called when the operation has completed successfully. When completing the restore operation, the `kinAccount` param will contain the restored account.  
- `didCancel` is called when the user cancels the backup or restore operation.  
- `error` is called if there is an error in the backup or restore operation.

```swift
extension ViewController: KinBackupRestoreManagerDelegate {
    func kinBackupRestoreManagerDidComplete(_ manager: KinBackupRestoreManager, kinAccount: KinAccount?) {

    }

    func kinBackupRestoreManagerDidCancel(_ manager: KinBackupRestoreManager) {

    }

    func kinBackupRestoreManager(_ manager: KinBackupRestoreManager, error: Error) {

    }
}
```

#### Step 3 - Backup or Restore

Before you start using the Backup and Restore operations, you need to create a `KinClient` object.

###### Example of how to create a `KinClient` object:

```swift
let url = URL(string: "https://horizon-testnet.kininfrastructure.com")!
let appId = try! AppId("test")
let kinClient = KinClient(with: url, network: .testNet, appId: appId)
```

If you want to backup, you need the `KinAccount` object, which represents the account that you want to back up.

###### Example of how to get a `KinAccount` object:

```swift
let kinAccount = kinClient.accounts.first
```

For more details on `KinClient` and `KinAccount`, see [KinClient](https://kinecosystem.github.io/kin-website-docs/docs/documentation/ios-sdk#kinclient)
and [KinAccount](https://kinecosystem.github.io/kin-website-docs/docs/documentation/ios-sdk#kinaccount)

Now you can use the Backup and Restore operations. For each operation you can choose for it to be presented or pushed onto a navigation stack.

###### Example of how to backup with the UI being presented:

```swift
backupRestoreManager.backup(kinAccount, presentedOnto: viewController)
```

###### Example of how to backup with the UI being pushed:

```swift
backupRestoreManager.backup(kinAccount, pushedOnto: navigationController)
```

###### Example of how to restore with the UI being presented:

```swift
backupRestoreManager.restore(kinClient, presentedOnto: viewController)
```

###### Example of how to restore with the UI being pushed:

```swift
backupRestoreManager.restore(kinClient, pushedOnto: navigationController)
```

### Error Handling

`kinBackupRestoreManager(_:, error:)` can be called if an error has occured while trying to backup or restore.

### Testing

For a full list of tests, see:

- https://github.com/kinecosystem/kin-backup-restore-module-ios/tree/master/KinBackupRestoreModule/KinBackupRestoreModuleTests

### Building from Source

To build from source, clone the repo:

```bash
$ git clone https://github.com/kinecosystem/kin-backup-restore-module-ios.git
```

Now you can build the library using gradle or open the project using Android Studio.

## Sample App Code

The `KinBackupRestoreSampleApp` covers the entire functionality of the `KinBackupRestoreModule` and serves as a detailed example of how to use the library.
The sample app source code can be found [here](https://github.com/kinecosystem/kin-backup-restore-module-ios/tree/master/KinBackupRestoreSampleApp).
