//
//  SheetsAPI.swift
//  App
//
//  Created by Ash Thwaites on 22/03/2019.
//

import Vapor

public protocol SheetsAPI {
    func get(sheet: String, queryParameters: [String: String]?) throws -> Future<SpreadSheet>
    func create() throws -> Future<SpreadSheet>
    func copySheet(sheet: Int, fromSpreadSheet: String, toSpreadSheet: String ) throws -> Future<SheetProperties>
}

extension SheetsAPI {

    func get(sheet: String, queryParameters: [String: String]? = nil) throws -> Future<SpreadSheet> {
        return try get(sheet: sheet, queryParameters: queryParameters)
    }

    func create() throws -> Future<SpreadSheet> {
        return try create()
    }

    func copySheet(sheet: Int, fromSpreadSheet: String, toSpreadSheet: String ) throws -> Future<SheetProperties> {
        return try copySheet(sheet: sheet, fromSpreadSheet: fromSpreadSheet, toSpreadSheet:toSpreadSheet )
    }

}

public final class GoogleSheetsAPI: SheetsAPI {
    let endpoint = "https://sheets.googleapis.com/v4/spreadsheets"
    let request: GoogleSheetsRequest

    init(request: GoogleSheetsRequest) {
        self.request = request
    }

    public func get(sheet: String, queryParameters: [String: String]? = nil) throws -> Future<SpreadSheet> {
        return try request
            .send(method: .GET, path: "\(endpoint)/\(sheet)", query: queryParameters?.queryParameters ?? "", body: .empty)
    }

    public func create() throws -> Future<SpreadSheet> {
        return try request
            .send(method: .POST, path: "\(endpoint)", query: "", body: .empty)
    }

    public func copySheet(sheet: Int, fromSpreadSheet: String, toSpreadSheet: String ) throws -> Future<SheetProperties> {

        let requestBody = try JSONEncoder().encode(["destinationSpreadsheetId": toSpreadSheet]).convertToHTTPBody()
        return try request
            .send(method: .POST, path: "\(endpoint)/\(fromSpreadSheet)/sheets/\(sheet):copyTo", query: "", body: requestBody)
    }
}

