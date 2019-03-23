//
//  SpreadSheet.swift
//  GoogleCloud
//
//  Created by Ash Thwaites on 22/03/2019.
//

import Vapor

public struct SpreadSheet: GoogleCloudModel {
    public var spreadsheetId: String
    public var properties: SpreadSheetProperties
    public var sheets: [Sheet]?
}

public struct SpreadSheetProperties: GoogleCloudModel {
    public var title: String
    public var locale: String
    public var autoRecalc: String
    public var timeZone: String
}

public struct Sheet: GoogleCloudModel {
    public var properties: SheetProperties
}

public struct SheetProperties: GoogleCloudModel {
    public var sheetId: Int
    public var title: String
    public var index: Int
    public var sheetType: String
    public var gridProperties: GridProperties
}

public struct GridProperties: GoogleCloudModel {
    public var rowCount: Int
    public var columnCount: Int
    public var hideGridlines: Bool?
}

public struct SheetUpdateValuesRequest: GoogleCloudModel {
    public var range: String
    public var majorDimension: String
    public var values: [[String?]]

    public init(range: String,
                majorDimension: String,
                values: [[String?]]) {
        self.range = range
        self.majorDimension = majorDimension
        self.values = values
    }
}

public struct SheetUpdateValuesResponse: GoogleCloudModel {
    public var spreadsheetId: String
    public var updatedRange: String
    public var updatedRows: Int
    public var updatedColumns: Int
    public var updatedCells: Int
}


public struct SheetGetValuesResponse: GoogleCloudModel {
    public var range: String
    public var majorDimension: String
    public var values: [[String?]]
}
