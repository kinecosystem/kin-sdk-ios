//
//  AccountResponseTests.swift
//  KinSDKTests
//
//  Created by Corey Werner on 22/07/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK

class AccountResponseTests: XCTestCase {
    let endpoint = URL(string: "https://horizon-testnet.kininfrastructure.com")!
    let account = "GC5I6A6RYD32IV5VNBMQOQAMVPYGWS6TIAGFTJ7QW3M47R4I2CHFFUR6"

    func testAccountResponseDecoding() {
        let expectation = XCTestExpectation()
        let url = Endpoint(endpoint).account(account).url

        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            if let error = error {
                XCTAssertTrue(false, "Something went wrong: \(error)")
                return
            }

            guard let data = data else {
                XCTAssertTrue(false, "Data should not be nil")
                return
            }

            do {
                _ = try JSONDecoder().decode(AccountResponse.self, from: data)
            }
            catch {
                XCTAssertTrue(false, "Something went wrong: \(error)")
            }

            expectation.fulfill()
        })
        .resume()

        wait(for: [expectation], timeout: 10)
    }
}
