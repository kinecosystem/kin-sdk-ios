//
//  StellarOps.swift
//  StellarKit
//
//  Created by Kin Foundation.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation

extension Operation {
    public static func createAccount(destination: String,
                                     balance: Kin,
                                     sourcePublicAddress: String? = nil) -> Operation {
        let destPK = PublicKey.PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: destination)))

        var sourcePK: PublicKey? = nil
        if let sourcePublicAddress = sourcePublicAddress {
            sourcePK = PublicKey.PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: sourcePublicAddress)))
        }

        let account = CreateAccountOp(destination: destPK, balance: balance.toQuarkAsBlockchainUnit())

        return Operation(sourceAccount: sourcePK, body: Operation.Body.CREATE_ACCOUNT(account))
    }
    
    public static func payment(destination: String,
                               amount: Kin,
                               sourcePublicAddress: String? = nil) -> Operation {
        let destPK = PublicKey.PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: destination)))

        var sourcePK: PublicKey? = nil
        if let sourcePublicAddress = sourcePublicAddress {
            sourcePK = PublicKey.PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: sourcePublicAddress)))
        }

        let payment = PaymentOp(destination: destPK, asset: .native, amount: amount.toQuarkAsBlockchainUnit())

        return Operation(sourceAccount: sourcePK, body: Operation.Body.PAYMENT(payment))

    }

    public static func manageData(key: String, value: Data?, sourcePublicAddress: String? = nil) -> Operation {
        var sourcePK: PublicKey? = nil
        if let sourcePublicAddress = sourcePublicAddress {
            sourcePK = PublicKey.PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: sourcePublicAddress)))
        }

        return Operation(sourceAccount: sourcePK,
                         body: Operation.Body.MANAGE_DATA(ManageDataOp(dataName: key, dataValue: value)))
    }
}
