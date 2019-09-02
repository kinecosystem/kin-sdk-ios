//
//  AsynchronousOperation.swift
//  KinSDK
//
//  Created by Corey Werner on 01/09/2019.
//  Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

class AsynchronousOperation: Foundation.Operation {
    private(set) public var state = State.ready {
        willSet {
            willChangeValue(forKey: state.key)
            willChangeValue(forKey: newValue.key)
        }
        didSet {
            didChangeValue(forKey: oldValue.key)
            didChangeValue(forKey: state.key)
        }
    }

    final override public var isAsynchronous: Bool {
        return true
    }

    final override public var isExecuting: Bool {
        return state == .executing
    }

    final override public var isFinished: Bool {
        return state == .finished
    }

    final override public var isReady: Bool {
        return state == .ready
    }

    final public func markFinished() {
        state = .finished
    }

    final override public func start() {
        if isCancelled {
            state = .finished
            return
        }

        main()
    }

    final override public func main() {
        if isCancelled {
            state = .finished
            return
        }

        state = .executing
        workItem()
    }

    func workItem() {
        markFinished()
    }
}

extension AsynchronousOperation {
    enum State {
        case ready
        case executing
        case finished
    }
}

extension AsynchronousOperation.State {
    fileprivate var key: String {
        switch self {
        case .ready:
            return "isReady"
        case .executing:
            return "isExecuting"
        case .finished:
            return "isFinished"
        }
    }
}
