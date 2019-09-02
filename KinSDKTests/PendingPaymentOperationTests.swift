//
//  PendingPaymentOperationTests.swift
//  KinSDKTests
//
//  Created by Corey Werner on 02/09/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK

class PendingPaymentOperationTests: XCTestCase {
    var kinClient: KinClient!
    var account0: KinAccount!
    var account1: KinAccount!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        kinClient = KinClientTests.createKinClient()

        account0 = KinAccountTests.createAccount(kinClient: kinClient)
        account1 = KinAccountTests.createAccount(kinClient: kinClient)
    }

    override func tearDown() {
        super.tearDown()

        kinClient.deleteKeystore()
    }

    func testPendingPaymentWith() {
//        let pendingPayment = PendingPayment(destinationPublicAddress: <#T##String#>, sourcePublicAddress: <#T##String#>, amount: <#T##Kin#>)
    }
}
