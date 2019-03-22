//
//  SheetsScope.swift
//  App
//
//  Created by Ash Thwaites on 22/03/2019.
//

import Foundation

public struct SheetsScope {
    /// Allows read-only access to the user's sheets and their properties.
    public static let readOnly = "https://www.googleapis.com/auth/spreadsheets.readonly"
    /// Allows read/write access to the user's sheets and their properties.
    public static let readWrite = "https://www.googleapis.com/auth/spreadsheets"
    /// Allows read-only access to the user's file metadata and file content.
    public static let driveReadWrite = "https://www.googleapis.com/auth/drive.readonly"
    /// Per-file access to files created or opened by the app.
    public static let driveFile = "https://www.googleapis.com/auth/drive.file"
    /// Full, permissive scope to access all of a user's files. Request this scope only when it is strictly necessary.
    public static let driveFull = "https://www.googleapis.com/auth/drive"
}
