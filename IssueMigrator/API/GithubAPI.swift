//
//  GithubAPI.swift
//  IssueMigrator
//
//  Created by Drew R. Hood on 3/13/18.
//  Copyright © 2018 Drew R. Hood. All rights reserved.
//

import Foundation

class GithubAPI {
    private let host: URL
    
    /// API Token
    private let apiToken: String
    
    private struct APIEndpoints {
        static let importIssue = "import/issues"
        
        private init() {}
    }
    
    private let apiBase = "repos"
    
    private let encoder = JSONEncoder()
    
    /// Access the Github API with the given access token.
    init(token: String) {
        self.host = URL(string: "https://api.github.com/\(self.apiBase)")!
        self.apiToken = token
        self.encoder.outputFormatting = .prettyPrinted
    }
    
    enum GithubError: Error {
        /// Repo/resource not found
        case notFound
        
        /// Response from server couldn't be interpreted.
        /// Underlying error may be provided.
        case marshallingError(Error?)
        
        /// Other errors, includes source error
        case unknown(Error?)
    }
    
    // MARK: - Helpers
    
    /// Provides a URLRequest suitable for POSTing to the API
    private func postRequest(forEndpoint path: String, body: Data) -> URLRequest {
        var request = URLRequest(url: self.host.appendingPathComponent(path), cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5.0)
        request.addValue("token \(self.apiToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.github.golden-comet-preview", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = body
        
        return request
    }
    
    private func marshal<T>(_ value: T) throws -> Data where T: Encodable {
        do {
            return try self.encoder.encode(value)
        } catch {
            throw GithubError.marshallingError(error)
        }
    }
    
    // MARK: - API Access
    
    /// Create given issue in given repo. Repository name should be in
    /// the format `<User/Org>/<RepoName>`.
    func create(issue: GithubIssue, inRepository repo: String) throws {
        // Encode issue
        let encodedBody = try self.marshal(GithubIssueWrapper(issue: issue))
        
        // Set up request
        let endpoint = "\(repo)/\(APIEndpoints.importIssue)"
        let request = self.postRequest(forEndpoint: endpoint, body: encodedBody)
        
        // Perform request.
        let result = URLSession.shared.syncDataTask(request)
        
        // Handle result. We expect 202 - Accepted
        if let error = result.error {
            throw GithubError.unknown(error)
        }
        
        guard let statusCode = result.httpStatus else {
            throw GithubError.unknown(nil)
        }
        
        if statusCode == 404 {
            throw GithubError.notFound
        } else if statusCode != 202 {
            throw GithubError.unknown(nil)
        }
    }
}
