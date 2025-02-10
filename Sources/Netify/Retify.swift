//
//  Retify.swift
//  Netify
//
//  Created by Akbar Umetov on 7/2/25.
//

import Foundation

/// Декоратор для добавления механизма повторных попыток к сетевым запросам
///
/// Автоматически повторяет неудачные запросы с экспоненциальной задержкой
public final class Retify: Netify {
    private let decorated: Netify
    /// Максимальное количество повторных попыток
    private let maxRetries: Int
    /// Начальная задержка между попытками в секундах
    private let initialDelay: TimeInterval
    
    /// Создает новый экземпляр Retify
    /// - Parameters:
    ///   - decorated: Базовый сетевой клиент
    ///   - maxRetries: Максимальное количество повторных попыток (по умолчанию 3)
    ///   - initialDelay: Начальная задержка между попытками в секундах (по умолчанию 1.0)
    public init(
        decorated: Netify,
        maxRetries: Int = 3,
        initialDelay: TimeInterval = 1.0
    ) {
        self.decorated = decorated
        self.maxRetries = maxRetries
        self.initialDelay = initialDelay
    }
    
    public func performRequest<T: Decodable>(
        _ endpoint: Endpoint,
        method: HTTPMethod,
        type: T.Type,
        body: Encodable?
    ) async throws -> T {
        var currentAttempt = 0
        var lastError: Error?
        
        while currentAttempt <= maxRetries {
            do {
                let result = try await decorated.performRequest(endpoint, method: method, type: T.self, body: body)
                return result
            } catch let error {
                lastError = error
                
                if shouldRetry(error: error) && currentAttempt < maxRetries {
                    // Экспоненциальный backoff
                    let delay = initialDelay * pow(2.0, Double(currentAttempt))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    currentAttempt += 1
                    continue
                } else {
                    throw error
                }
            }
        }
        throw lastError ?? NetworkError.unknown(statusCode: -1)
    }
    
    private func shouldRetry(error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .networkConnectionLost, .notConnectedToInternet:
                return true
            default:
                return false
            }
        }
        
        if let networkError = error as? NetworkError {
            switch networkError {
            case .serverError(let statusCode), .serverUnavailable(let statusCode):
                return (500...599).contains(statusCode)
            default:
                return false
            }
        }
        
        return false
    }
}
