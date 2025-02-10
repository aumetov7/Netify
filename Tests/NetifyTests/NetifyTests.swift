import XCTest
@testable import Netify

final class NetifyTests: XCTestCase {
    var netify: Netify!
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        netify = NetifyImpl(session: session)
    }
    
    override func tearDown() {
        netify = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testRequestSuccess() async throws {
        let expectedModel = TestModel(id: 1, name: "Test")
        let jsonData = try JSONEncoder().encode(expectedModel)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            return (response, jsonData)
        }
        
        let endpoint = Endpoint(host: "example.com", path: "/test")
        let model: TestModel = try await netify.request(endpoint, method: .get, type: TestModel.self, body: nil)
        XCTAssertEqual(model, expectedModel)
    }
    
    func testRequestUnauthorized() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            
            return (response, Data())
        }
        
        let endpoint = Endpoint(host: "example.com", path: "/test")
        do {
            let _: TestModel = try await netify.request(endpoint, method: .get, type: TestModel.self, body: nil)
            XCTFail("Ожидалась ошибка unauthorized, но запрос прошёл успешно.")
        } catch let error as NetworkError {
            switch error {
            case .unauthorized(let statusCode):
                XCTAssertEqual(statusCode, 401)
            default:
                XCTFail("Ожидалась ошибка unauthorized, получена ошибка: \(error)")
            }
        }
    }
    
    func testEmptyResponse() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 204,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }
        let endpoint = Endpoint(host: "example.com", path: "/test")
        let result: EmptyResponse = try await netify.request(endpoint, method: .get, type: EmptyResponse.self, body: nil)
        XCTAssertNotNil(result)
    }
}

