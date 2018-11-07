//
//  Promise.swift
//  KinUtil
//
//  Created by Kin Foundation.
//  Copyright © 2018 Kin Foundation. All rights reserved.
//

import Foundation
import Dispatch

public enum Result<Value> {
    case value(Value)
    case error(Error)
}

public class Promise<Value>: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Promise [\(Unmanaged<AnyObject>.passUnretained(self as AnyObject).toOpaque())]"
    }

    private var callbacks = [((Result<Value>) -> Void)]()
    private var errorHandler: ((Error) -> Void)?
    private var errorTransform: ((Error) -> Error) = { return $0 }
    private var finalHandler: (() -> ())?

    public private(set) var result: Result<Value>? {
        didSet {
            callbacks.forEach { c in result.map { c($0) } }

            if let result = result {
                switch result {
                case .value:
                    break
                case .error(let error):
                    errorHandler?(errorTransform(error))

                    errorHandler = nil

                    invokeFinally()
                }
            }

            if callbacks.isEmpty {
                invokeFinally()
            }
        }
    }

    private func invokeFinally() {
        finalHandler?()
        finalHandler = nil
    }

    public init() {

    }

    public convenience init(_ value: Value) {
        self.init()

        result = .value(value)
    }

    public convenience init(_ error: Error) {
        self.init()

        result = .error(error)
    }

    @discardableResult
    public func signal(_ value: Value) -> Promise {
        return signal(value: value)
    }

    @discardableResult
    public func signal(_ error: Error) -> Promise {
        return signal(error: error)
    }

    @discardableResult
    public func signal(value: Value) -> Promise {
        result = .value(value)

        return self
    }

    @discardableResult
    public func signal(error: Error) -> Promise {
        result = .error(error)

        return self
    }

    private func observe(_ callback: @escaping (Result<Value>) -> Void) {
        callbacks.append(callback)

        result.map { callback($0) }
    }

    @discardableResult
    public func then(on queue: DispatchQueue? = nil,
                     _ handler: @escaping (Value) throws -> Void) -> Promise {
        let p = Promise<Value>()
        p.errorTransform = errorTransform

        observe { result in
            let block =  {
                switch result {
                case .value(let value):
                    do {
                        try handler(value)

                        p.signal(value)
                    }
                    catch {
                        p.signal(error)
                    }
                case .error(let error):
                    p.signal(error)
                }
            }

            if let queue = queue {
                queue.async(execute: block)
            } else {
                block()
            }
        }

        return p
    }

    @discardableResult
    public func then<NewValue>(on queue: DispatchQueue? = nil,
                               _ handler: @escaping (Value) throws -> Promise<NewValue>) -> Promise<NewValue>{
        let p = Promise<NewValue>()
        p.errorTransform = errorTransform

        observe { result in
            let block = {
                switch result {
                case .value(let value):
                    do {
                        let promise = try handler(value)

                        promise.observe { result in
                            switch result {
                            case .value(let value):
                                p.signal(value)
                            case .error(let error):
                                p.signal(error)
                            }
                        }
                    }
                    catch {
                        p.signal(error)
                    }

                case .error(let error):
                    p.signal(error)
                }
            }

            if let queue = queue {
                queue.async(execute: block)
            } else {
                block()
            }
        }

        return p
    }

    public func transformError(_ handler: @escaping (Error) -> Error) -> Promise {
        errorTransform = handler

        return self
    }

    @discardableResult
    public func error(_ handler: @escaping (Error) -> Void) -> Promise {
        if let result = result {
            switch result {
            case .value:
                break
            case .error(let error):
                handler(errorTransform(error))

                invokeFinally()
            }

            return self
        }

        errorHandler = handler

        return self
    }

    public func finally(_ handler: @escaping () -> ()) {
        if result != nil {
            handler()
        }
        else {
            finalHandler = handler
        }
    }
}

public func attempt<T>(_ tries: Int, retryInterval: TimeInterval = 0.0, closure: @escaping (Int) throws -> Promise<T>) -> Promise<T> {
    return attempt(retryIntervals: Array(repeating: retryInterval, count: tries - 1), closure: closure)
}

public func attempt<T>(retryIntervals: [TimeInterval], closure: @escaping (Int) throws -> Promise<T>) -> Promise<T> {
    let p = Promise<T>()

    let tries = retryIntervals.count + 1

    var attempts = 0

    var attempt2 = {}

    let attempt1 = {
        attempts += 1

        do {
            try closure(attempts)
                .then({
                    p.signal($0)
                })
                .error({
                    if attempts < tries {
                        DispatchQueue.global().asyncAfter(deadline: .now() + retryIntervals[attempts - 1]) {
                            attempt2()
                        }

                        return
                    }

                    p.signal($0)
                })
        }
        catch {
            p.signal(error)
        }
    }

    attempt2 = {
        attempts += 1

        do {
            try closure(attempts)
                .then({
                    p.signal($0)
                })
                .error({
                    if attempts < tries {
                        DispatchQueue.global().asyncAfter(deadline: .now() + retryIntervals[attempts - 1]) {
                            attempt1()
                        }

                        return
                    }

                    p.signal($0)
                })
        }
        catch {
            p.signal(error)
        }
    }

    attempt1()

    return p
}
