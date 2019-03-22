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
    public var sheets: [Sheet]
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
