//
//  Extensions.swift
//  Netify
//
//  Created by Akbar Umetov on 7/2/25.
//

import Foundation

public extension URLRequest {
    /// Создает URLRequest на основе Endpoint
    /// - Parameter endpoint: Конечная точка для запроса
    init(endpoint: Endpoint) {
        self.init(url: endpoint.url)
        self.allHTTPHeaderFields = endpoint.headers
    }
}

public extension JSONDecoder {
    /// Стандартный декодер JSON с настроенной стратегией декодирования ключей
    ///
    /// Автоматически конвертирует snake_case в camelCase
    static let defaultDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

public extension JSONEncoder {
    /// Стандартный энкодер JSON с настроенной стратегией кодирования ключей
    ///
    /// Автоматически конвертирует camelCase в snake_case
    static let defaultEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
}
