//
//  URLSession.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 03.12.2024.
//

import Foundation
import NetworkExtension

public extension URLSession {
    typealias RequestResult = Result<(data: Data, response: URLResponse),Error>
    
    /// Convenience method to load data using a `URLRequest`.
    /// It embed's creation and resuming a `URLSessionDataTask` into ``Future`` monad.
    ///
    /// - Parameter request: The `URLRequest` for which to load data.
    /// - Returns: ``Future`` containing request result
    @inlinable func future(for request: URLRequest) -> Future<RequestResult> {
        Future {
            do {
                let response = try await self.data(for: request)
                return .success(response)
            } catch {
                return .failure(error)
            }
        }
    }
    
    /// Convenience method to load data using a `URL`.
    /// It embed's creation and resuming a `URLSessionDataTask` into ``Future`` monad.
    ///
    /// - Parameter url: The `URL` for which to load data.
    /// - Returns: ``Future`` containing request result
    @inlinable func future(from url: URL) -> Future<RequestResult> {
        Future {
            do {
                let response = try await self.data(from: url)
                return .success(response)
            } catch {
                return .failure(error)
            }
        }
    }

}
