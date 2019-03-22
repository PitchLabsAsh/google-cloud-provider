//
//  SheetsConfig.swift
//  App
//
//  Created by Ash Thwaites on 22/03/2019.
//

import Vapor

public struct GoogleSheetsConfig: Service, GoogleCloudAPIConfig {

    public let scope: [String]
    public let serviceAccount: String
    public let project: String?

    public init(scope: [String], serviceAccount: String, project: String?) {
        self.scope = scope
        self.serviceAccount = serviceAccount
        self.project = project
    }

    /// Create a new `GoogleSheetsConfig` with full control scope and the default service account.
    public static func `default`() -> GoogleSheetsConfig {
        return GoogleSheetsConfig(scope: [SheetsScope.readWrite], serviceAccount: "default", project: nil)
    }
}

