//
//  SessionConfigurator.swift
//  Netify
//
//  Created by Akbar Umetov on 7/2/25.
//

import Foundation

/// Конфигуратор сессии URLSession
///
/// Предоставляет удобный способ настройки параметров URLSession
public struct SessionConfigurator {
    /// Базовая конфигурация сессии
    let configuration: URLSessionConfiguration
    
    /// Максимальное время ожидания запроса
    let timeoutInterval: TimeInterval
    
    /// Кэш для хранения ответов
    let cache: URLCache
    
    /// Политика кэширования запросов
    let cachePolicy: NSURLRequest.CachePolicy
    
    /// Создает новый конфигуратор сессии
    /// - Parameters:
    ///   - configuration: Базовая конфигурация (по умолчанию .default)
    ///   - timeoutInterval: Время ожидания в секундах (по умолчанию 30)
    ///   - cache: URLCache для кэширования (по умолчанию 10MB в памяти, 50MB на диске)
    ///   - cachePolicy: Политика кэширования (по умолчанию .returnCacheDataElseLoad)
    public init(
        configuration: URLSessionConfiguration = .default,
        timeoutInterval: TimeInterval = 30,
        cache: URLCache = {
            URLCache(
                memoryCapacity: 10 * 1024 * 1024,
                diskCapacity: 50 * 1024 * 1024
            )
        }(),
        cachePolicy: NSURLRequest.CachePolicy = .returnCacheDataElseLoad
    ) {
        self.configuration = configuration
        self.timeoutInterval = timeoutInterval
        self.cache = cache
        self.cachePolicy = cachePolicy
    }
    
    public func configure() -> URLSession {
        let config = configuration
        config.timeoutIntervalForRequest = timeoutInterval
        config.urlCache = cache
        config.requestCachePolicy = cachePolicy
        
        return URLSession(configuration: config)
    }
}
