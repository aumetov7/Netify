//
//  NetifyProtocols.swift
//  Netify
//
//  Created by Akbar Umetov on 7/2/25.
//

import Foundation

/// Протокол для выполнения HTTP-запросов
///
/// Этот протокол определяет основной интерфейс для выполнения сетевых запросов
/// с поддержкой различных HTTP-методов и автоматической декодификацией ответов.
public protocol Netify {
    /// Выполняет HTTP-запрос и декодирует ответ в указанный тип
    /// - Parameters:
    ///   - endpoint: Конечная точка запроса, содержащая URL и дополнительные параметры
    ///   - method: HTTP-метод запроса (GET, POST, PUT, DELETE)
    ///   - type: Тип, в который нужно декодировать ответ
    ///   - body: Опциональное тело запроса для методов POST/PUT
    /// - Returns: Декодированный объект указанного типа
    /// - Throws: `NetworkError` в случае ошибок сети или декодирования
    func performRequest<T: Decodable>(
        _ endpoint: Endpoint,
        method: HTTPMethod,
        type: T.Type,
        body: Encodable?
    ) async throws -> T
}

/// Протокол для работы с потоковыми данными
///
/// Этот протокол определяет методы для выполнения запросов,
/// которые возвращают данные в виде потока строк.
public protocol NetifyStreaming {
    /// Выполняет потоковый запрос
    /// - Parameters:
    ///   - endpoint: Конечная точка запроса
    ///   - method: HTTP-метод запроса
    ///   - body: Тело запроса
    /// - Returns: Асинхронный поток строк
    /// - Throws: `NetworkError` в случае ошибок сети
    func performStreamingRequest(
        _ endpoint: Endpoint,
        method: HTTPMethod,
        body: Encodable
    ) async throws -> AsyncThrowingStream<String, Error>
}

public extension Netify {
    /// Упрощенный метод для выполнения HTTP-запроса
    /// - Parameters:
    ///   - endpoint: Конечная точка запроса
    ///   - method: HTTP-метод (по умолчанию .get)
    ///   - type: Тип, в который нужно декодировать ответ
    ///   - body: Опциональное тело запроса
    /// - Returns: Декодированный объект указанного типа
    /// - Throws: `NetworkError` в случае ошибок
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        method: HTTPMethod = .get,
        type: T.Type,
        body: Encodable? = nil
    ) async throws -> T {
        try await performRequest(endpoint, method: method, type: type, body: body)
    }
}

public extension NetifyStreaming {
    /// Упрощенный метод для выполнения потокового запроса
    /// - Parameters:
    ///   - endpoint: Конечная точка запроса
    ///   - method: HTTP-метод (по умолчанию .post)
    ///   - body: Тело запроса
    /// - Returns: Асинхронный поток строк
    /// - Throws: `NetworkError` в случае ошибок
    func streamingRequest(
        _ endpoint: Endpoint,
        method: HTTPMethod = .post,
        body: Encodable
    ) async throws -> AsyncThrowingStream<String, Error> {
        try await performStreamingRequest(endpoint, method: method, body: body)
    }
}
