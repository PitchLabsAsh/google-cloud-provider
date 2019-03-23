//
//  SheetsAPI.swift
//  App
//
//  Created by Ash Thwaites on 22/03/2019.
//

import Vapor

public protocol SheetsAPI {
    func getSpreadSheet(spreadSheet: String) throws -> Future<SpreadSheet>
    func createSpreadSheet() throws -> Future<SpreadSheet>
    func copySheet(sheet: Int, fromSpreadSheet: String, toSpreadSheet: String ) throws -> Future<SheetProperties>
    func deleteSheet(sheet: Int, fromSpreadSheet: String ) throws -> Future<SheetProperties>
    func updateValues(spreadSheet: String, updateRequest: SheetUpdateValuesRequest) throws -> Future<SheetUpdateValuesResponse>
    func getValues(spreadSheet: String, forRange: String) throws -> Future<SheetGetValuesResponse>
}

public final class GoogleSheetsAPI: SheetsAPI {
    let endpoint = "https://sheets.googleapis.com/v4/spreadsheets"
    let request: GoogleSheetsRequest

    init(request: GoogleSheetsRequest) {
        self.request = request
    }

    public func getSpreadSheet(spreadSheet: String) throws -> Future<SpreadSheet> {
        return try request
            .send(method: .GET, path: "\(endpoint)/\(spreadSheet)", query: "", body: .empty)
    }

    public func createSpreadSheet() throws -> Future<SpreadSheet> {
        return try request
            .send(method: .POST, path: "\(endpoint)", query: "", body: .empty)
    }

    public func copySheet(sheet: Int, fromSpreadSheet: String, toSpreadSheet: String ) throws -> Future<SheetProperties> {

        let requestBody = try JSONEncoder().encode(["destinationSpreadsheetId": toSpreadSheet]).convertToHTTPBody()
        return try request
            .send(method: .POST, path: "\(endpoint)/\(fromSpreadSheet)/sheets/\(sheet):copyTo", query: "", body: requestBody)
    }

    public func deleteSheet(sheet: Int, fromSpreadSheet: String ) throws -> Future<SheetProperties> {

        let requestBody = try JSONEncoder().encode(["requests": ["deleteSheet": ["sheetId":sheet]]]).convertToHTTPBody()
        return try request
            .send(method: .POST, path: "\(endpoint)/\(fromSpreadSheet):batchUpdate", query: "", body: requestBody)
    }

    public func updateValues(spreadSheet: String, updateRequest: SheetUpdateValuesRequest)  throws -> Future<SheetUpdateValuesResponse> {
        let body = try JSONSerialization.data(withJSONObject: try updateRequest.toEncodedDictionary()).convertToHTTPBody()
        let queryParams = ["valueInputOption": "USER_ENTERED"].queryParameters
        return try request
            .send(method: .PUT, path: "\(endpoint)/\(spreadSheet)/values/\(updateRequest.range)", query: queryParams , body: body)
    }

    public func getValues(spreadSheet: String, forRange: String)  throws -> Future<SheetGetValuesResponse> {
        return try request
            .send(method: .GET, path: "\(endpoint)/\(spreadSheet)/values/\(forRange)", query: "" , body: .empty)
    }

}

