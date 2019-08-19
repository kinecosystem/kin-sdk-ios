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
                                     balance: Int64,
                                     sourcePublicAddress: String? = nil) -> Operation {
        let destPK = PublicKey.PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: destination)))

        var sourcePK: PublicKey? = nil
        if let sourcePublicAddress = sourcePublicAddress {
            sourcePK = PublicKey.PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: sourcePublicAddress)))
        }

        return Operation(sourceAccount: sourcePK,
                         body: Operation.Body.CREATE_ACCOUNT(CreateAccountOp(destination: destPK,
                                                                             balance: balance)))
    }
    
    public static func payment(destination: String,
                               amount: Int64,
                               asset: Asset,
                               sourcePublicAddress: String? = nil) -> Operation {
        let destPK = PublicKey.PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: destination)))

        var sourcePK: PublicKey? = nil
        if let sourcePublicAddress = sourcePublicAddress {
            sourcePK = PublicKey.PUBLIC_KEY_TYPE_ED25519(WD32(BCKeyUtils.key(base32: sourcePublicAddress)))
        }

        return Operation(sourceAccount: sourcePK,
                         body: Operation.Body.PAYMENT(PaymentOp(destination: destPK,
                                                                asset: asset,
                                                                amount: amount)))

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
