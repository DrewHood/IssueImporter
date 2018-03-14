//
//  APIFetcher.swift
//  IssueMigrator
//
//  Created by Drew R. Hood on 3/13/18.
//  Copyright © 2018 Drew R. Hood. All rights reserved.
//

import Foundation

extension URLSession {
    /// Synchronously returns data from a URLRequest. Blocks until
    /// the request succeeds, fails, or times out.
    func syncDataTask(_ request: URLRequest) -> (data: Data?, httpStatus: Int?, error: Error?) {
        var data: Data?
        var httpStatus: Int?
        var error: Error?
        
        let sema = DispatchSemaphore(value: 0)
        
        // Perform request
        let task = URLSession.shared.dataTask(with: request) {
            requestData, requestResponse, requestError in
            data = requestData
            error = requestError
            
            if let response = requestResponse as? HTTPURLResponse {
                httpStatus = response.statusCode
            }
            
            sema.signal()
        }
        task.resume()

        _ = sema.wait(timeout: .distantFuture)
        
        return (data: data, httpStatus: httpStatus, error: error)
    }
}
