import XCTest
@testable import Netify

final class RetifyTests: XCTestCase {
    
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
    
    func testRetifySucceedsAfterRetries() async throws {
        var callCount = 0
        
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            if callCount < 3 {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 500,
                    httpVersion: nil,
                    headerFields: nil
                )!
                
                return (response, Data())
            } else {
                let model = TestModel(id: 1, name: "Test")
                let data = try JSONEncoder().encode(model)
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                
                return (response, data)
            }
        }
        
        let retryClient = Retify(decorated: netify, maxRetries: 3, initialDelay: 0.1)
        
        let endpoint = Endpoint(host: "example.com", path: "/test")
        let model: TestModel = try await retryClient.performRequest(endpoint,
                                                                    method: .get,
                                                                    type: TestModel.self,
                                                                    body: nil)
        
        XCTAssertEqual(model.id, 1)
        XCTAssertEqual(callCount, 3, "Ожидалось, что успех придёт после 2 неудачных попыток.")
    }
}

