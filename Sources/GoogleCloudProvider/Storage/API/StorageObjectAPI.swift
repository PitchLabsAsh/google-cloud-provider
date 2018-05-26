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
    func delete(bucket: String, objectName: String, queryParameters: [String: String]?) throws -> Future<EmptyResponse>
    func get(bucket: String, objectName: String, queryParameters: [String: String]?) throws -> Future<GoogleStorageObject>
    func createSimpleUpload(bucket: String, data: Data, name: String, mediaType: MediaType, queryParameters: [String: String]?) throws -> Future<GoogleStorageObject>
    func list(bucket: String, queryParameters: [String: String]?) throws -> Future<StorageObjectList>
    func patch(bucket: String, objectName: String, object: GoogleStorageObject?, queryParameters: [String: String]?) throws -> Future<GoogleStorageObject>
    func rewrite(destinationBucket: String, destinationObject: String, sourceBucket: String, sourceObject: String, object: GoogleStorageObject?, queryParameters: [String: String]?) throws -> Future<StorageRewriteObject>
    func update(bucket: String, objectName: String, object: GoogleStorageObject, queryParameters: [String: String]?) throws -> Future<GoogleStorageObject>
    func watchAll(bucket: String, notificationChannel: StorageNotificationChannel, queryParameters: [String: String]?) throws -> Future<StorageNotificationChannel>
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
        
        let body = try JSONSerialization.data(withJSONObject: try composeRequest.toEncodedDictionary()).convertToHTTPBody()
        
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
        
        let body = try JSONSerialization.data(withJSONObject: try object.toEncodedDictionary()).convertToHTTPBody()
        
        return try request.send(method: .POST, path: "\(endpoint)/\(sourceBucket)/o/\(sourceObject)/copyTo/b/\(destinationBucket)/o/\(destinationObject)", query: queryParams, body: body)
    }
    
    /// Deletes an object and its metadata. Deletions are permanent if versioning is not enabled for the bucket, or if the generation parameter is used.
    public func delete(bucket: String,
                       objectName: String,
                       queryParameters: [String: String]? = nil) throws -> Future<EmptyResponse> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        return try request.send(method: .DELETE, path: "\(endpoint)/\(bucket)/o/\(objectName)", query: queryParams)
    }
    
    /// Retrieves an object or its metadata.
    public func get(bucket: String, objectName: String, queryParameters: [String: String]? = nil) throws -> Future<GoogleStorageObject> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        return try request.send(method: .GET, path: "\(endpoint)/\(bucket)/o/\(objectName)", query: queryParams)
    }
    
    /// Stores a new object and metadata. Upload the media only, without any metadata.
    public func createSimpleUpload(bucket: String,
                                   data: Data,
                                   name: String,
                                   mediaType: MediaType,
                                   queryParameters: [String: String]? = nil) throws -> Future<GoogleStorageObject> {
        var queryParams = ""
        if var queryParameters = queryParameters {
            queryParameters["name"] = name
            queryParameters["uploadType"] = "media"
            queryParams = queryParameters.queryParameters
        }
        else {
            queryParams = "uploadType=media&name=\(name)"
        }
        
        let body = data.convertToHTTPBody()
        
        let headers: HTTPHeaders = [HTTPHeaderName.contentType.description: mediaType.description]
        
        return try request.send(method: .POST, headers: headers, path: "https://www.googleapis.com/upload/storage/v1/b/\(bucket)/o", query: queryParams, body: body)
    }
    
    /// Retrieves a list of objects matching the criteria.
    public func list(bucket: String,
                     queryParameters: [String: String]? = nil) throws -> EventLoopFuture<StorageObjectList> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        return try request.send(method: .GET, path: "\(endpoint)/\(bucket)/o)", query: queryParams)
    }
    
    /// Updates a data blob's associated metadata. This method supports patch semantics
    public func patch(bucket: String,
                      objectName: String,
                      object: GoogleStorageObject? = nil,
                      queryParameters: [String: String]? = nil) throws -> Future<GoogleStorageObject> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        var body = ""
        
        if let object = object {
            body = try JSONSerialization.data(withJSONObject: try object.toEncodedDictionary()).convert(to: String.self)
        }
        
        return try request.send(method: .PATCH, path: "\(endpoint)/\(bucket)/o)", query: queryParams, body: body.convertToHTTPBody())
    }
    
    /// Rewrites a source object to a destination object. Optionally overrides metadata.
    public func rewrite(destinationBucket: String,
                        destinationObject: String,
                        sourceBucket: String,
                        sourceObject: String,
                        object: GoogleStorageObject? = nil,
                        queryParameters: [String: String]? = nil) throws -> Future<StorageRewriteObject> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        var body = ""
        
        if let object = object {
            body = try JSONSerialization.data(withJSONObject: try object.toEncodedDictionary()).convert(to: String.self)
        }
        
        return try request.send(method: .POST, path: "\(endpoint)/\(sourceBucket)/o/\(sourceObject)/rewriteTo/b/\(destinationBucket)/o/\(destinationObject)", query: queryParams, body: body.convertToHTTPBody())
    }
    
    /// Updates an object's metadata.
    public func update(bucket: String,
                       objectName: String,
                       object: GoogleStorageObject,
                       queryParameters: [String: String]? = nil) throws -> Future<GoogleStorageObject> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        let body = try JSONSerialization.data(withJSONObject: try object.toEncodedDictionary()).convertToHTTPBody()
        
        return try request.send(method: .PUT, path: "\(endpoint)/\(bucket)/o)", query: queryParams, body: body)
    }
    
    /// Watch for changes on all objects in a bucket.
    public func watchAll(bucket: String,
                         notificationChannel: StorageNotificationChannel,
                         queryParameters: [String: String]? = nil) throws -> Future<StorageNotificationChannel> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        let body = try JSONSerialization.data(withJSONObject: try notificationChannel.toEncodedDictionary()).convertToHTTPBody()
        
        return try request.send(method: .POST, path: "\(endpoint)/\(bucket)/o/watch)", query: queryParams, body: body)
    }
}
