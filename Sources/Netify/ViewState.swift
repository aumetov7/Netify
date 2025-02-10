//
//  ViewState.swift
//  Netify
//
//  Created by Akbar Umetov on 6/2/25.
//

import Foundation

/// Состояния представления при работе с сетевыми запросами
///
/// Используется для отслеживания состояния загрузки данных
/// и обработки ошибок в UI
public enum ViewState {
    /// Начальное состояние
    case initial
    
    /// Данные загружаются
    case loading
    
    /// Данные успешно загружены
    case loaded
    
    /// Произошла ошибка при загрузке
    case error(NetworkError)
}
