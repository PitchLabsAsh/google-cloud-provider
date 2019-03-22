//
//  SheetsClient.swift
//  App
//
//  Created by Ash Thwaites on 22/03/2019.
//

import Vapor

public enum GoogleSheetsError: GoogleCloudError {
    case projectIdMissing
    case unknownError(String)

    var localizedDescription: String {
        switch self {
        case .projectIdMissing:
            return "Missing project id for GoogleSheets API. Did you forget to set your project id?"
        case .unknownError(let reason):
            return "An unknown error occured: \(reason)"
        }
    }

    public var identifier: String {
        switch self {
        case .projectIdMissing:
            return "missing-project-id"
        case .unknownError(_):
            return "unknown"
        }
    }

    public var reason: String { return localizedDescription }
}

public protocol SheetsClient: ServiceType {
    var sheets: SheetsAPI { get set }
}

public final class GoogleSheetsClient: SheetsClient {
    public var sheets: SheetsAPI

    init(providerconfig: GoogleCloudProviderConfig, sheetsConfig: GoogleSheetsConfig, client: Client) throws {
        // A token implementing OAuthRefreshable. Loaded from credentials from the provider config.
        let refreshableToken = try OAuthCredentialLoader.getRefreshableToken(credentialFilePath: providerconfig.serviceAccountCredentialPath,
                                                                             withConfig: sheetsConfig,
                                                                             andClient: client)

        // Set the projectId to use for this client. In order of priority:
        // - Environment Variable (PROJECT_ID)
        // - Service Account's projectID
        // - GoogleSheetsConfig's .project (optionally configured)
        // - GoogleCloudProviderConfig's .project (optionally configured)
        guard let projectId = ProcessInfo.processInfo.environment["PROJECT_ID"] ??
            (refreshableToken as? OAuthServiceAccount)?.credentials.projectId ??
            sheetsConfig.project ?? providerconfig.project else {
                throw GoogleSheetsError.projectIdMissing
        }

        let sheetsRequest = GoogleSheetsRequest(httpClient: client, oauth: refreshableToken, project: projectId)
        sheets = GoogleSheetsAPI(request: sheetsRequest) as SheetsAPI
    }

    public static var serviceSupports: [Any.Type] { return [GoogleSheetsClient.self] }

    public static func makeService(for worker: Container) throws -> GoogleSheetsClient {
        let client = try worker.make(Client.self)
        let providerConfig = try worker.make(GoogleCloudProviderConfig.self)
        let sheetsConfig = try worker.make(GoogleSheetsConfig.self)
        return try GoogleSheetsClient(providerconfig: providerConfig, sheetsConfig: sheetsConfig, client: client)
    }
}
