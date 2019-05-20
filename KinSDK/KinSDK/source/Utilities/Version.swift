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

    func kinDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        var kinRequest = request
        kinRequest.setValue(Bundle.kin.version, forHTTPHeaderField: URLSession.versionHeaderField)
        return dataTask(with: kinRequest, completionHandler: completionHandler)
    }
}
