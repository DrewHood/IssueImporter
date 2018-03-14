//
//  GitlabAPI.swift
//  IssueMigrator
//
//  Created by Drew R. Hood on 3/13/18.
//  Copyright © 2018 Drew R. Hood. All rights reserved.
//

import Foundation

/// Synchronous access to the Gitlab v4 API.
class GitlabAPI {
    /// Hostname of a Gitlab instance
    let host: URL
    
    /// API Token
    private let apiToken: String
    
    private struct APIEndpoints {
        static let projects = "projects"
        static let issues = "issues"
        static let notes = "notes"
        
        private init() {}
    }
    
    private let apiBase = "api/v4"
    
    /// Create a new API access point for a given host
    /// with the provided token.
    init(host: String, token: String) throws {
        guard let hostURL = URL(string: "https://\(host)/\(self.apiBase)") else {
            throw GitlabError.improperlyConfigured
        }
        self.host = hostURL
        self.apiToken = token
    }
    
    private lazy var decoder = JSONDecoder()
    
    // MARK: - Errors
    
    /// Errors that can occur with the Gitlab API
    enum GitlabError: Error {
        /// Resource not found
        case notFound
        
        /// Improper configuration
        case improperlyConfigured
        
        /// Response from server couldn't be interpreted.
        /// Underlying error may be provided.
        case marshallingError(Error?)
        
        /// Other errors, includes source error
        case unknown(Error?)
    }
    
    private func urlRequest(forEndpoint path: String) -> URLRequest {
        let resourceURL = self.host.appendingPathComponent(path)
        
        var request = URLRequest(url: resourceURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5.0)
        request.setValue(apiToken, forHTTPHeaderField: "PRIVATE-TOKEN")
        
        return request
    }
    
    // MARK: - Response Marshalling
    
    private func marshal<T: Decodable>(type: T.Type, withData data: Data) throws -> T {
        do {
            return try self.decoder.decode(type, from: data)
        } catch {
            throw GitlabError.marshallingError(error)
        }
    }
    
    // MARK: - API Access
    
    /// Retrieve a `GitlabIssue` on the given project
    /// with the given IID.
    func issue(id: Int, inProjectId projectId: Int) throws -> GitlabIssue {
        // Construct URL
        let resourcePath = "\(APIEndpoints.projects)/\(projectId)/\(APIEndpoints.issues)/\(id)"
        let request = self.urlRequest(forEndpoint: resourcePath)
        
        // Perform request.
        let result = URLSession.shared.syncDataTask(request)
        
        if let error = result.error {
            throw GitlabError.unknown(error)
        }
        
        guard let statusCode = result.httpStatus else {
            throw GitlabError.unknown(nil)
        }
        
        switch statusCode {
        case 404:
            throw GitlabError.notFound
        default:
            // Attempt to marshal the response data into a GitlabIssue
            guard let data = result.data else {
                throw GitlabError.unknown(nil)
            }
            return try self.marshal(type: GitlabIssue.self, withData: data)
        }
    }
    
    /// Retrieve `GitlabComment`s associated with an issue.
    func comments(forIssueId id: Int, inProjectId projectId: Int) throws -> [GitlabComment] {
        let resourcePath = "\(APIEndpoints.projects)/\(projectId)/\(APIEndpoints.issues)/\(id)/\(APIEndpoints.notes)"
        let request = self.urlRequest(forEndpoint: resourcePath)
        
        // Perform request
        let result = URLSession.shared.syncDataTask(request)
        
        if let error = result.error {
            throw GitlabError.unknown(error)
        }
        
        guard let statusCode = result.httpStatus else {
            throw GitlabError.unknown(nil)
        }
        
        switch statusCode {
        case 404:
            throw GitlabError.notFound
        default:
            // Attempt to marshal the response data into a GitlabIssue
            guard let data = result.data else {
                throw GitlabError.unknown(nil)
            }
            return try self.marshal(type: [GitlabComment].self, withData: data)
        }
    }
}
