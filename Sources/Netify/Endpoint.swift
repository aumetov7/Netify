//
//  Endpoint.swift
//  Netify
//
//  Created by Akbar Umetov on 6/2/25.
//

import Foundation

/// Структура, представляющая конечную точку API
///
/// Содержит всю необходимую информацию для формирования URL-запроса,
/// включая схему, хост, путь, параметры запроса и заголовки.
public struct Endpoint {
    /// Схема URL (например, "https")
    let scheme: String
    
    /// Хост (например, "api.example.com")
    let host: String
    
    /// Путь к ресурсу (например, "/v1/users")
    let path: String
    
    /// Параметры запроса
    var queryItems: [URLQueryItem]
    
    /// HTTP-заголовки
    let headers: [String: String]
    
    /// Создает новый endpoint
    /// - Parameters:
    ///   - scheme: Схема URL (по умолчанию "https")
    ///   - host: Хост сервера
    ///   - path: Путь к ресурсу
    ///   - queryItems: Параметры запроса (по умолчанию пустой массив)
    ///   - headers: HTTP-заголовки (по умолчанию включает Content-Type: application/json)
    public init(
        scheme: String = "https",
        host: String,
        path: String,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = ["Content-Type": "application/json"]
    ) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.queryItems = queryItems
        self.headers = headers
    }
}

public extension Endpoint {
    /// Сформированный URL на основе параметров endpoint'а
    ///
    /// - Returns: Полный URL для выполнения запроса
    /// - Precondition: Все компоненты URL должны быть валидными
    var url: URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        
        return url
    }
}

public extension Endpoint {
    func with(_ queryItems: [URLQueryItem]) -> Endpoint {
        var copy = self
        copy.queryItems = queryItems
        return copy
    }
}
