//
//  Essentials.swift
//  KinSDK
//
//  Created by Corey Werner on 11/09/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class PreEssentials {
    let stellar: Stellar
    let network: Network
    let appId: AppId

    init(stellar: Stellar, network: Network, appId: AppId) {
        self.stellar = stellar
        self.network = network
        self.appId = appId
    }
}

class Essentials: PreEssentials {
    let stellarAccount: StellarAccount

    init(stellar: Stellar, network: Network, appId: AppId, stellarAccount: StellarAccount) {
        self.stellarAccount = stellarAccount
        super.init(stellar: stellar, network: network, appId: appId)
    }

    convenience init(preEssentials: PreEssentials, stellarAccount: StellarAccount) {
        self.init(stellar: preEssentials.stellar, network: preEssentials.network, appId: preEssentials.appId, stellarAccount: stellarAccount)
    }
}
