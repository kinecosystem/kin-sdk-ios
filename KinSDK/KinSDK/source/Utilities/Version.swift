//
// Version.swift
// KinSDK
//
// Created by Kin Foundation.
// Copyright © 2019 Kin Foundation. All rights reserved.
//

import Foundation

extension Bundle {
    var version: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
}

extension URLSession {
    static let versionHeaderField = "kin-sdk-ios-version"

    private func applyVersion(to request: URLRequest) -> URLRequest {
        var _request = request
        _request.setValue(Bundle.kin.version, forHTTPHeaderField: URLSession.versionHeaderField)
        return _request
    }

    func kinDataTask(with request: URLRequest) -> URLSessionDataTask {
        return dataTask(with: applyVersion(to: request))
    }

    func kinDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return dataTask(with: applyVersion(to: request), completionHandler: completionHandler)
    }
}

extension URLSessionConfiguration {
    static func kinAdditionalHeaders(_ headers: [AnyHashable : Any]? = nil) -> [AnyHashable : Any] {
        var _headers = headers ?? [:]
        _headers[URLSession.versionHeaderField] = Bundle.kin.version
        return _headers
    }
}
