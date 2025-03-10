//
//  URLSession.swift
//  SwiftFP
//
//  Created by Илья Шаповалов on 25.12.2024.
//

import Foundation

public extension URLSession {
    
    /// Convenience method to load data using a URLRequest,
    /// creates and resumes a URLSessionDataTask internally.
    ///
    /// - Parameter request: The URLRequest for which to load data.
    /// - Returns: `Result` object, contains Data and response or `Error`.
    @inlinable
    @Sendable
    func result(
        for request: URLRequest
    ) async -> Result<(data: Data, response: URLResponse), Error> {
        await Result { try await data(for: request) }
    }
    
    /// Convenience method to load data using a URL, creates and resumes a URLSessionDataTask internally.
    ///
    /// - Parameter url: The URL for which to load data.
    /// - Returns: `Result` object, contains Data and response or `Error`.
    @inlinable
    @Sendable
    func result(
        from url: URL
    ) async -> Result<(data: Data, response: URLResponse), Error> {
        await Result { try await data(from: url) }
    }
    
    /// Convenience method to upload data using a URLRequest, creates and resumes a URLSessionUploadTask internally.
    ///
    /// - Parameter request: The URLRequest for which to upload data.
    /// - Parameter fileURL: File to upload.
    /// - Returns: `Result` object, contains Data and response or `Error`.
    @inlinable
    @Sendable
    func upload(
        for request: URLRequest,
        fromFile fileURL: URL
    ) async -> Result<(data: Data, response: URLResponse), Error> {
        await Result { try await upload(for: request, fromFile: fileURL) }
    }
    
    /// Convenience method to upload data using a URLRequest,
    /// creates and resumes a URLSessionUploadTask internally.
    ///
    /// - Parameter request: The URLRequest for which to upload data.
    /// - Parameter bodyData: Data to upload.
    /// - Returns: `Result` object, contains Data and response or `Error`.
    @inlinable
    @Sendable
    func upload(
        for request: URLRequest,
        from bodyData: Data
    ) async -> Result<(data: Data, response: URLResponse), Error> {
        await Result { try await upload(for: request, from: bodyData) }
    }
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public extension URLSession {
    
    /// Convenience method to load data using a URLRequest,
    /// creates and resumes a URLSessionDataTask internally.
    ///
    /// - Parameter request: The URLRequest for which to load data.
    /// - Parameter delegate: Task-specific delegate.
    /// - Returns: `Result` object, contains Data and response or `Error`.
    @inlinable
    @Sendable
    func result(
        for request: URLRequest,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async -> Result<(data: Data, response: URLResponse), Error> {
        await Result { try await data(for: request, delegate: delegate) }
    }
    
    /// Convenience method to load data using a URL, creates and resumes a URLSessionDataTask internally.
    ///
    /// - Parameter url: The URL for which to load data.
    /// - Parameter delegate: Task-specific delegate.
    /// - Returns: `Result` object, contains Data and response or `Error`.
    @inlinable
    @Sendable
    func data(
        from url: URL,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async -> Result<(data: Data, response: URLResponse), Error> {
        await Result { try await data(from: url, delegate: delegate) }
    }

}
