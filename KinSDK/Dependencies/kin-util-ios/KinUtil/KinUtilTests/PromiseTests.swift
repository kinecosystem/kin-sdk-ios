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
                XCTFail("Shouldn't reach here.")
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
                XCTFail("Shouldn't reach here.")
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
                XCTFail("Shouldn't reach here.")
            }
            .mapError { _ in
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
                XCTFail("Shouldn't reach here.")
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
            .mapError { _ in
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
                XCTFail("Shouldn't reach here.")
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
                XCTFail("Shouldn't reach here.")
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

    func test_signal_first() {
        let e = expectation(description: "")

        let p = Promise<Int>()
        p.signal(1)

        p.then { _ in
            e.fulfill()
        }

        wait(for: [e], timeout: 0.1)
    }

    func test_signal_second() {
        let e = expectation(description: "")

        let p = Promise<Int>()

        p.then { _ in
            e.fulfill()
        }

        p.signal(1)

        wait(for: [e], timeout: 0.1)
    }

    func test_signal_last_async() {
        let e = expectation(description: "")

        let p = Promise<Int>()

        p.then { _ in
            e.fulfill()
        }

        DispatchQueue.global().async { p.signal(1) }

        wait(for: [e], timeout: 0.1)
    }

    func test_signal_first_async() {
        let e = expectation(description: "")

        let p = Promise<Int>()

        DispatchQueue.global().async { p.signal(1) }

        p.then { _ in
            e.fulfill()
        }

        wait(for: [e], timeout: 0.1)
    }

    func test_signal_first_then_async() {
        let e = expectation(description: "")

        let p = Promise<Int>()

        p.signal(1)

        DispatchQueue.global().async {
            p.then { _ in
                e.fulfill()
            }
        }

        wait(for: [e], timeout: 0.1)
    }

    func test_signal_last_then_async() {
        let e = expectation(description: "")

        let p = Promise<Int>()

        DispatchQueue.global().async {
            p.then { _ in
                e.fulfill()
            }
        }

        p.signal(1)

        wait(for: [e], timeout: 0.1)
    }

    func test_chain_of_promise() {
        let e1 = expectation(description: "")
        let e2 = expectation(description: "")

        let p = Promise<Int>()
        p.signal(1)

        p.then { _ -> Promise<Int> in
            e1.fulfill()

            return Promise<Int>(2)
            }
            .then { _ in e2.fulfill() }

        wait(for: [e1, e2], timeout: 0.1)
    }

    func test_chain_of_value() {
        let e1 = expectation(description: "")
        let e2 = expectation(description: "")

        let p = Promise<Int>()
        p.signal(1)

        p.then { _ -> Int in
            e1.fulfill()

            return 2
            }
            .then { _ in e2.fulfill() }

        wait(for: [e1, e2], timeout: 0.1)
    }

    func test_signal_error() {
        let e = expectation(description: "")

        Promise<Int>(TestError("a"))
            .then { _ in XCTFail() }
            .error { _ in e.fulfill() }

        wait(for: [e], timeout: 0.1)
    }

    func test_chain_signal_error_on_first() {
        let e = expectation(description: "")

        Promise<Int>(TestError("a"))
            .then { _ in return Promise(2) }
            .error { _ in e.fulfill() }

        wait(for: [e], timeout: 0.1)
    }

    func test_chain_signal_error_on_second() {
        let e = expectation(description: "")

        Promise<Int>(1)
            .then { _ in return Promise<Int>(TestError("b")) }
            .error { _ in e.fulfill() }

        wait(for: [e], timeout: 0.1)
    }

    func test_chain_throw_error_on_second() {
        let e = expectation(description: "")

        Promise<Int>(1)
            .then { _ in throw TestError("b") }
            .error { _ in e.fulfill() }

        wait(for: [e], timeout: 0.1)
    }

    func test_triple_chain_throw_error_on_second() {
        let e = expectation(description: "")

        Promise<Int>(1)
            .then { _ in throw TestError("b") }
            .then { _ -> String in XCTFail(); return "c" }
            .error { _ in e.fulfill() }

        wait(for: [e], timeout: 0.1)
    }

    func test_queue() {
        let e = expectation(description: "")

        let p = Promise<Int>(1)

        p.then(on: DispatchQueue.global()) { _ in
            e.fulfill()
        }

        wait(for: [e], timeout: 0.1)
    }

    func test_finally() {
        let e = expectation(description: "")

        let p = Promise<Int>(1)

        p
            .then { _ in }
            .finally { e.fulfill() }

        wait(for: [e], timeout: 0.1)
    }

    func test_finally_after_error() {
        let e = expectation(description: "")

        let p = Promise<Int>(TestError("a"))

        p
            .then { _ in }
            .error { _ in }
            .finally { e.fulfill() }

        wait(for: [e], timeout: 0.1)
    }

    func test_finally_after_chain() {
        let e = expectation(description: "")

        let p = Promise<Int>(1)

        p
            .then { _ in return Promise(2) }
            .error { _ in }
            .finally { e.fulfill() }

        wait(for: [e], timeout: 0.1)
    }

    func test_map_error() {
        let e = expectation(description: "")

        let p = Promise<Int>(TestError("a"))

        p
            .mapError { _ in return TestError("b") }
            .error({
                if let err = $0 as? TestError {
                    XCTAssertEqual(err.m, "b")
                    e.fulfill()
                }
            })

        wait(for: [e], timeout: 0.1)
    }

}
