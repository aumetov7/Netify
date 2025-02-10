//
//  Netify.swift
//  Netify
//
//  Created by Akbar Umetov on 6/2/25.
//

import Foundation
import Logify

public final class NetifyImpl: Netify, NetifyStreaming {
    private let session: URLSession
    
    let log: Logify?
    
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    /// Создает новый экземпляр NetifyImpl
    /// - Parameters:
    ///   - session: URLSession для выполнения запросов
    ///   - jsonDecoder: Декодер JSON (по умолчанию .defaultDecoder)
    ///   - jsonEncoder: Энкодер JSON (по умолчанию .defaultEncoder)
    public init(
        session: URLSession,
        jsonDecoder: JSONDecoder = .defaultDecoder,
        jsonEncoder: JSONEncoder = .defaultEncoder,
        log: Logify? = nil
    ) {
        self.session = session
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
        self.log = log
    }
    
    public func performRequest<T: Decodable>(
        _ endpoint: Endpoint,
        method: HTTPMethod,
        type: T.Type,
        body: Encodable?
    ) async throws -> T {
        var request = URLRequest(endpoint: endpoint)
        request.httpMethod = method.rawValue
        
        if let body {
            request.httpBody = try jsonEncoder.encode(body)
        }
        
        log?.logRequest(request)
        
        do {
            let (data, response) = try await session.data(for: request)
            log?.logResponse(response, data: data)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(statusCode: -1)
            }
            
            try handleError(for: httpResponse)
            
            if data.isEmpty {
                if httpResponse.statusCode == 204 {
                    return EmptyResponse() as! T
                } else if httpResponse.statusCode == 200 {
                    throw NetworkError.emptyResponse
                }
            }

            return try jsonDecoder.decode(T.self, from: data)
        } catch let error as URLError {
            throw NetifyImpl.mapURLError(error)
        }
    }
    
    public func performStreamingRequest(
        _ endpoint: Endpoint,
        method: HTTPMethod = .post,
        body: Encodable
    ) async throws -> AsyncThrowingStream<String, Error> {
        var request = URLRequest(endpoint: endpoint)
        request.httpMethod = method.rawValue
        request.httpBody = try jsonEncoder.encode(body)
        
        
        let (stream, response) = try await requestBytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(statusCode: -1)
        }
        
        try handleError(for: httpResponse)
        
        return AsyncThrowingStream { continuation in
            Task(priority: .high) {
                do {
                    for try await line in stream.lines {
                        continuation.yield(line)
                    }
                    continuation.finish()
                } catch let error as URLError {
                    continuation.finish(throwing: NetifyImpl.mapURLError(error))
                }
            }
        }
    }

    private func requestBytes(for request: URLRequest) async throws -> (URLSession.AsyncBytes, URLResponse) {
        do {
            return try await session.bytes(for: request)
        } catch let error as URLError {
            throw NetifyImpl.mapURLError(error)
        }
    }
}

private extension NetifyImpl {
    private static func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .unknown:
            return .unknown(statusCode: error.errorCode)
        case .cancelled:
            return .requestCancelled
        case .badURL:
            return .invalidURL(statusCode: error.errorCode)
        case .timedOut:
            return .timeout
        case .unsupportedURL:
            return .unsupportedURL(statusCode: error.errorCode)
        case .cannotFindHost:
            return .cannotFindHost(statusCode: error.errorCode)
        case .cannotConnectToHost:
            return .cannotConnectToHost(statusCode: error.errorCode)
        case .networkConnectionLost:
            return .lostConnection
        case .dnsLookupFailed:
            return .dnsLookupFailed(statusCode: error.errorCode)
        case .httpTooManyRedirects:
            return .httpTooManyRedirects(statusCode: error.errorCode)
        case .notConnectedToInternet:
            return .noConnection
        default:
            return .unknown(statusCode: error.errorCode)
        }
    }
    
    func handleError(for response: HTTPURLResponse) throws {
        let statusCode = response.statusCode
        guard !(200...299).contains(statusCode) else { return }
        
        let (message, error) = errorForStatusCode(statusCode)
        logError(.error, for: .networking, with: message, response: response)
        
        throw error
    }
    
    func errorForStatusCode(_ statusCode: Int) -> (message: String, error: NetworkError) {
        switch statusCode {
        case 400:
            return ("Bad request", .badRequest(statusCode: 400))
        case 401:
            return ("Unauthorized", .unauthorized(statusCode: 401))
        case 404:
            return ("Invalid URL", .invalidURL(statusCode: 404))
        case 413:
            return ("Payload too large", .payloadTooLarge(statusCode: 413))
        case 429:
            return ("Too many requests", .tooManyRequests(statusCode: 429))
        case 402..<500:
            return ("Server unavailable", .serverUnavailable(statusCode: statusCode))
        case 500...599:
            return ("Server error", .serverError(statusCode: statusCode))
        default:
            return ("Unknown error", .unknown(statusCode: statusCode))
        }
    }
    
    func logError(
        _ level: LogLevel = .debug,
        for category: LogCategory = .networking,
        with message: String,
        response: URLResponse? = nil
    ) {
        guard
            let response = (response as? HTTPURLResponse),
            let url = response.url?.absoluteString
        else {
            return
        }
        
        let fullMessage = "\(message). \(url). Status Code: \(response.statusCode)"
        log?.log(level, category: category, fullMessage)
    }
}
