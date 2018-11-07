//
//  PromiseTests.swift
//  KinUtilTests
//
//  Created by Kin Foundation.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinUtil

class PromiseTests: XCTestCase {

    struct TestError: Error {
        let m: String

        init(_ m: String) {
            self.m = m
        }
    }

    func asyncPromise(_ x: Int, delay: TimeInterval = 0.0) -> Promise<Int> {
        let p = Promise<Int>()

        DispatchQueue(label: "").asyncAfter(deadline: .now() + delay) {
            p.signal(x)
        }

        return p
    }

    func asyncError(_ m: String) -> Promise<Int> {
        let p = Promise<Int>()

        DispatchQueue(label: "").async {
            p.signal(TestError(m))
        }

        return p
    }

    func test_async_then() {
        let e = expectation(description: "")

        asyncPromise(1)
            .then { x -> Void in
                XCTAssertEqual(x, Int?(1))
            }
            .error { error in
                XCTAssert(false, "Shouldn't reach here.")
            }
            .finally {
                e.fulfill()
        }

        wait(for: [e], timeout: 1.0)
    }

    func test_async_error() {
        let e = expectation(description: "")

        asyncError("a")
            .then { _ -> Void in
                XCTAssert(false, "Shouldn't reach here.")
            }
            .error { error in
                XCTAssertEqual((error as? TestError)?.m, "a")
            }
            .finally {
                e.fulfill()
        }

        wait(for: [e], timeout: 1.0)
    }

    func test_async_finally() {
        let e = expectation(description: "")

        asyncPromise(1)
            .finally {
                e.fulfill()
        }

        wait(for: [e], timeout: 1.0)
    }

    func test_async_nested_chain_with_outer_finally() {
        let e = expectation(description: "")

        var s = ""

        asyncPromise(1, delay: 1.0)
            .then { x -> Promise<Int> in
                return self.asyncPromise(2, delay: 1.0)
                    .then({ _ -> Promise<Int> in
                        s = "a"
                        return self.asyncPromise(3)
                    })
                    .then({ _ in })
            }
            .error { error in
                XCTAssertTrue(false, "Unexpected error: \(error)")
            }
            .finally {
                XCTAssertEqual(s, "a")
                e.fulfill()
        }

        wait(for: [e], timeout: 10.0)
    }

    func test_async_error_with_transform() {
        let e = expectation(description: "")

        asyncError("a")
            .then { _ -> Void in
                XCTAssert(false, "Shouldn't reach here.")
            }
            .transformError { _ in
                return TestError("b")
            }
            .error { error in
                XCTAssertEqual((error as? TestError)?.m, "b")
            }
            .finally {
                e.fulfill()
        }

        wait(for: [e], timeout: 1.0)
    }

    func test_async_chain() {
        let e = expectation(description: "")

        asyncPromise(1)
            .then { x -> Promise<Int> in
                return self.asyncPromise(2)
            }
            .then { x -> Void in
                XCTAssertEqual(x, Int?(2))
            }
            .error { error in
                XCTAssert(false, "Shouldn't reach here.")
            }
            .finally {
                e.fulfill()
        }

        wait(for: [e], timeout: 1.0)
    }

    func test_async_then_returning_error() {
        let e = expectation(description: "")

        asyncPromise(1)
            .then { x -> Promise<Int> in
                throw TestError("a")
            }
            .error { error in
                XCTAssertEqual((error as? TestError)?.m, "a")
            }
            .finally {
                e.fulfill()
        }

        wait(for: [e], timeout: 1.0)
    }

    func test_async_then_returning_error_with_transform() {
        let e = expectation(description: "")

        asyncPromise(1)
            .then { x -> Promise<Int> in
                throw TestError("a")
            }
            .transformError { _ in
                return TestError("b")
            }
            .error { error in
                XCTAssertEqual((error as? TestError)?.m, "b")
            }
            .finally {
                e.fulfill()
        }

        wait(for: [e], timeout: 1.0)
    }

    func test_async_chain_with_first_link_returning_error() {
        let e = expectation(description: "")

        asyncPromise(1)
            .then { x -> Promise<Int> in
                XCTAssertEqual(x, Int?(1))

                throw TestError("a")
            }
            .then { _ -> Void in
                XCTAssert(false, "Shouldn't reach here.")
            }
            .error { error in
                XCTAssertEqual((error as? TestError)?.m, "a")
            }
            .finally {
                e.fulfill()
        }

        wait(for: [e], timeout: 1.0)
    }

    func test_async_chain_with_last_link_returning_error() {
        let e = expectation(description: "")

        asyncPromise(1)
            .then { x -> Promise<Int> in
                return self.asyncPromise(2)
            }
            .then { _ -> Promise<Int> in
                throw TestError("a")
            }
            .error { error in
                XCTAssertEqual((error as? TestError)?.m, "a")
            }
            .finally {
                e.fulfill()
        }

        wait(for: [e], timeout: 1.0)
    }

    func test_attempt_with_immediate_success() {
        let e = expectation(description: "")

        var attempts = 0
        attempt(2) { _ -> Promise<Int> in
            attempts += 1
            return self.asyncPromise(1)
            }
            .then({ _ in
                e.fulfill()
            })
            .error({
                XCTAssert(false, "Received unexpected error: \($0)")
            })

        wait(for: [e], timeout: 1.0)

        XCTAssertEqual(attempts, 1)
    }

    func test_attempt_with_immediate_failure() {
        let e = expectation(description: "")

        var attempts = 0
        attempt(2) { _ -> Promise<Int> in
            attempts += 1
            throw TestError("b")
            }
            .then({ _ in
                XCTAssert(false, "Received unexpected success")
            })
            .error({
                if let e = $0 as? TestError {
                    XCTAssertEqual(e.m, "b")
                }
                else {
                    XCTAssert(false, "Received unexpected error: \($0)")
                }

                e.fulfill()
            })

        wait(for: [e], timeout: 1.0)

        XCTAssertEqual(attempts, 1)
    }

    func test_attempt_with_eventual_success() {
        let e = expectation(description: "")

        var attempts = 0
        attempt(2, closure: { _ -> Promise<Int> in
            attempts += 1

            if attempts == 1 {
                return self.asyncError("a")
            }
            else {
                return self.asyncPromise(1)
            }
        })
            .then({ _ in
                e.fulfill()
            })
            .error({
                XCTAssert(false, "Received unexpected error: \($0)")
            })

        wait(for: [e], timeout: 1.0)

        XCTAssertEqual(attempts, 2)
    }

    func test_attempt_without_success() {
        let e = expectation(description: "")

        var attempts = 0
        attempt(2) { _ -> Promise<Int> in
            attempts += 1
            return self.asyncError("a")
            }
            .then({ _ in
                throw TestError("b")
            })
            .error({
                if let e = $0 as? TestError {
                    XCTAssertNotEqual(e.m, "b")
                }
                else {
                    XCTAssert(false, "Received unexpected error: \($0)")
                }

                e.fulfill()
            })

        wait(for: [e], timeout: 1.0)

        XCTAssertEqual(attempts, 2)
    }

}
