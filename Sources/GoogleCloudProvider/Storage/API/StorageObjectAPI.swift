//
//  StorageObjectAPI.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 5/20/18.
//

import Vapor

public protocol StorageObjectAPI {
    func compose(destinationBucket: String, destinationObject: String, composeRequest: StorageComposeRequest, queryParameters: [String: String]?) throws -> Future<GoogleStorageObject>
    func copy(destinationBucket: String, destinationObject: String, sourceBucket: String, sourceObject: String, object: GoogleStorageObject, queryParameters: [String: String]?) throws -> Future<GoogleStorageObject>
    func delete(bucket: String, object: String, queryParameters: [String: String]?) throws -> Future<EmptyResponse>
    func get(bucket: String, object: String, queryParameters: [String: String]?) throws -> Future<GoogleStorageObject>
    func createSimpleUpload(bucket: String, data: Data, name: String, queryParameters: [String: String]?, object: GoogleStorageBucket?) throws -> Future<GoogleStorageBucket>
}

public class GoogleStorageObjectAPI: StorageObjectAPI {
    let endpoint = "https://www.googleapis.com/storage/v1/b"
    let request: GoogleCloudStorageRequest
    
    init(request: GoogleCloudStorageRequest) {
        self.request = request
    }

    /// Concatenates a list of existing objects into a new object in the same bucket.
    public func compose(destinationBucket: String,
                        destinationObject: String,
                        composeRequest: StorageComposeRequest,
                        queryParameters: [String: String]? = nil) throws -> Future<GoogleStorageObject> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        let body = try JSONSerialization.data(withJSONObject: try composeRequest.toEncodedDictionary()).convert(to: String.self)
        
        return try request.send(method: .POST, path: "\(endpoint)/\(destinationBucket)/o/\(destinationObject)/compose", query: queryParams, body: body)
    }
    
    /// Copies a source object to a destination object. Optionally overrides metadata.
    public func copy(destinationBucket: String,
                     destinationObject: String,
                     sourceBucket: String,
                     sourceObject: String,
                     object: GoogleStorageObject,
                     queryParameters: [String: String]? = nil) throws -> Future<GoogleStorageObject> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        let body = try JSONSerialization.data(withJSONObject: try object.toEncodedDictionary()).convert(to: String.self)
        
        return try request.send(method: .POST, path: "\(endpoint)/\(sourceBucket)/o/\(sourceObject)/copyTo/b/\(destinationBucket)/o/\(destinationObject)", query: queryParams, body: body)
    }
    
    /// Deletes an object and its metadata. Deletions are permanent if versioning is not enabled for the bucket, or if the generation parameter is used.
    public func delete(bucket: String,
                       object: String,
                       queryParameters: [String: String]? = nil) throws -> Future<EmptyResponse> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        return try request.send(method: .DELETE, path: "\(endpoint)/\(bucket)/o/\(object)", query: queryParams, body: "")
    }
    
    /// Retrieves an object or its metadata.
    public func get(bucket: String, object: String, queryParameters: [String: String]? = nil) throws -> Future<GoogleStorageObject> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        return try request.send(method: .GET, path: "\(endpoint)/\(bucket)/o/\(object)", query: queryParams, body: "")
    }
    
    /// Stores a new object and metadata. Upload the media only, without any metadata.
    public func createSimpleUpload(bucket: String,
                                   data: Data,
                                   name: String,
                                   queryParameters: [String: String]? = nil,
                                   object: GoogleStorageBucket? = nil) throws -> Future<GoogleStorageBucket> {
        var queryParams = ""
        if var queryParameters = queryParameters {
            queryParameters["name"] = name
            queryParameters["uploadType"] = "media"
            queryParams = queryParameters.queryParameters
        }
        else {
            queryParams = "uploadType=media&name=\(name)"
        }
        
        let body = data.convert(to: String.self)
        
        return try request.send(method: .POST, path: "https://www.googleapis.com/upload/storage/v1/b/\(bucket)/o", query: queryParams, body: body)
    }
}
