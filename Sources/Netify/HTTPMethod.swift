//
//  HTTPMethods.swift
//  Netify
//
//  Created by Akbar Umetov on 6/2/25.
//

import Foundation

/// HTTP-методы, поддерживаемые библиотекой
///
/// Определяет основные HTTP-методы для выполнения сетевых запросов
public enum HTTPMethod: String {
    /// GET-запрос для получения данных
    case get = "GET"
    
    /// POST-запрос для создания новых ресурсов
    case post = "POST"
    
    /// PUT-запрос для обновления существующих ресурсов
    case put = "PUT"
    
    /// DELETE-запрос для удаления ресурсов
    case delete = "DELETE"
}
