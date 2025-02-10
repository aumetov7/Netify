import XCTest
@testable import Netify

final class NetifyStreamingTest: XCTestCase {
    var netify: NetifyStreaming!
    
    struct DummyBody: Encodable {
        let key: String
    }
    
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
    
    func testPerformStreamingRequestSuccess() async throws {
        let streamingString = "line1\nline2\nline3\n"
        let streamingData = streamingString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            return (response, streamingData)
        }
        
        let endpoint = Endpoint(host: "example.com", path: "/test")
        let dummyBody = DummyBody(key: "value")
        
        let stream = try await netify.streamingRequest(endpoint, body: dummyBody)
        
        var receivedLines: [String] = []
        for try await line in stream {
            receivedLines.append(line)
        }
        
        XCTAssertEqual(receivedLines, ["line1", "line2", "line3"])
    }
    
    func testPerformStreamingRequestURLError() async throws {
        MockURLProtocol.requestHandler = { request in
            throw URLError(.notConnectedToInternet)
        }
        
        let endpoint = Endpoint(host: "example.com", path: "/test")
        let dummyBody = DummyBody(key: "value")
        
        do {
            _ = try await netify.streamingRequest(endpoint, body: dummyBody)
            XCTFail("Ожидалась ошибка, но метод завершился успешно.")
        } catch let error as NetworkError {
            if case .noConnection = error {
            } else {
                XCTFail("Ожидалась ошибка .noConnection, получена: \(error)")
            }
        }
    }
}
