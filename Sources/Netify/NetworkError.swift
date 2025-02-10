//
//  NetworkError.swift
//  Netify
//
//  Created by Akbar Umetov on 6/2/25.
//

import Foundation

/// Перечисление возможных сетевых ошибок
///
/// Предоставляет типизированные ошибки для различных сетевых проблем
/// и ошибок HTTP
public enum NetworkError: Error, LocalizedError, Equatable {
    /// Отсутствует подключение к интернету
    case noConnection
    
    /// Соединение было потеряно во время запроса
    case lostConnection
    
    /// Превышено время ожидания запроса
    case timeout
    
    /// Ошибка SSL/TLS
    case sslError
    
    /// Запрос был отменен
    case requestCancelled
    
    /// Сервер недоступен (обычно ошибки 503)
    case serverUnavailable(statusCode: Int)
    
    /// Неверный URL или ресурс не найден
    case invalidURL(statusCode: Int = 404)
    
    /// Ошибка декодирования ответа
    case decodingFailed
    
    /// Серверная ошибка (5xx)
    case serverError(statusCode: Int)
    
    /// Некорректный запрос (400)
    case badRequest(statusCode: Int = 400)
    
    /// Слишком большой размер данных (413)
    case payloadTooLarge(statusCode: Int = 413)
    
    /// Превышен лимит запросов (429)
    case tooManyRequests(statusCode: Int = 429)
    
    /// Неизвестная ошибка
    case unknown(statusCode: Int)
    
    /// Пустой ответ от сервера
    case emptyResponse
    
    /// Неавторизованный доступ (401)
    case unauthorized(statusCode: Int = 401)
    
    /// Неподдерживаемый URL
    case unsupportedURL(statusCode: Int)
    
    /// Невозможно найти хост
    case cannotFindHost(statusCode: Int)
    
    /// Невозможно подключиться к хосту
    case cannotConnectToHost(statusCode: Int)
    
    /// Ошибка DNS-поиска
    case dnsLookupFailed(statusCode: Int)
    
    /// Слишком много перенаправлений
    case httpTooManyRedirects(statusCode: Int)
    
    /// Поток тела запроса исчерпан
    case requestBodyStreamExhausted(statusCode: Int)
    
    public var errorDescription: String {
        switch self {
        case .noConnection:
            return "No internet connection."
        case .lostConnection:
            return "Connection lost during request."
        case .timeout:
            return "Request timed out."
        case .sslError:
            return "SSL error occurred."
        case .requestCancelled:
            return "Request was cancelled."
        case .serverUnavailable:
            return "Server is unavailable."
        case .invalidURL:
            return "Invalid URL."
        case .decodingFailed:
            return "Failed to decode response."
        case .serverError:
            return "Server error occurred."
        case .badRequest:
            return "Bad request."
        case .payloadTooLarge:
            return "Response payload too large."
        case .tooManyRequests:
            return "Too many requests. Slow down."
        case .unknown:
            return "Unknown error occurred."
        case .emptyResponse:
            return "Response was empty."
        case .unauthorized:
            return "Unauthorized request."
            
        case .unsupportedURL:
            return "Unsupported URL."
        case .cannotFindHost:
            return "Cannot find host."
        case .cannotConnectToHost:
            return "Cannot connect to host."
        case .dnsLookupFailed:
            return "DNS lookup failed."
        case .httpTooManyRedirects:
            return "HTTP too many redirects."
        case .requestBodyStreamExhausted:
            return "Request body stream exhausted."
        }
    }
}
