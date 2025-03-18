# Netify

🚀 **Netify** — это легковесная и гибкая библиотека для работы с сетью в iOS. Поддерживает `async/await`, обработку ошибок и логирование запросов.

## 📦 Установка

### Swift Package Manager (SPM)

Добавь в `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/aumetov7/Netify.git", from: "1.0.0")
]
```

Или добавь репозиторий в Xcode через **File > Add Packages...**.

## 🛠 Использование

### 🔗 1. Создание экземпляра `Netify`

```swift
import Netify
import Logify

let netify = NetifyImpl(
    session: URLSession.shared,
    log: Logify() // Опциональное логирование
)
```

### 📤 2. Отправка запроса

```swift
struct User: Decodable {
    let id: Int
    let name: String
}

let endpoint = Endpoint(path: "/users/1")

Task {
    do {
        let user: User = try await netify.performRequest(endpoint, method: .get, type: User.self)
        print("👤 User:", user)
    } catch {
        print("❌ Ошибка запроса:", error)
    }
}
```

### 📡 3. Стриминг данных

Если API возвращает поток данных, например, SSE или WebSockets, можно использовать `performStreamingRequest`:

```swift
let endpoint = Endpoint(path: "/stream")

Task {
    do {
        let stream = try await netify.performStreamingRequest(endpoint, method: .post, body: ["key": "value"])
        
        for try await line in stream {
            print("📥 Получено:", line)
        }
    } catch {
        print("❌ Ошибка стриминга:", error)
    }
}
```

### ⚠️ 4. Обработка ошибок

Netify обрабатывает `URLError` и HTTP-статусы:

```swift
catch let error as NetworkError {
    switch error {
    case .timeout:
        print("⏳ Таймаут запроса")
    case .noConnection:
        print("🌐 Нет интернета")
    case .serverError(let statusCode):
        print("💥 Ошибка сервера:", statusCode)
    default:
        print("🚨 Неизвестная ошибка:", error)
    }
}
```

## 🔧 Конфигурация

Можно передавать кастомные `JSONDecoder` и `JSONEncoder`:

```swift
let customDecoder = JSONDecoder()
customDecoder.keyDecodingStrategy = .convertFromSnakeCase

let netify = NetifyImpl(
    session: URLSession.shared,
    jsonDecoder: customDecoder,
    jsonEncoder: .init()
)
```

## 📜 Лицензия

Netify распространяется под лицензией **MIT**. Используй на здоровье! 🚀
