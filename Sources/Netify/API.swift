//
//  API.swift
//  Netify
//
//  Created by Akbar Umetov on 6/2/25.
//

import Foundation

/// Структура для конфигурации API-endpoints
///
/// Предоставляет удобный способ создания endpoint'ов с общим базовым URL
public struct API {
    /// Хост API (например, "api.example.com")
    let host: String
    
    /// Схема URL (например, "https")
    let scheme: String
    
    /// Инициализирует новый экземпляр API
    /// - Parameters:
    ///   - scheme: Схема URL (по умолчанию "https")
    ///   - host: Хост API
    public init(scheme: String = "https", host: String) {
        self.host = host
        self.scheme = scheme
    }
    
    /// Создает новый endpoint с указанными параметрами
    /// - Parameters:
    ///   - path: Путь endpoint'а (например, "/users")
    ///   - queryItems: Опциональные параметры запроса
    ///   - headers: HTTP-заголовки (по умолчанию включает Content-Type: application/json)
    /// - Returns: Сконфигурированный `Endpoint`
    public func endpoint(
        path: String,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = ["Content-Type": "application/json"]
    ) -> Endpoint {
        return Endpoint(
            scheme: scheme,
            host: host,
            path: path,
            queryItems: queryItems,
            headers: headers
        )
    }
}
