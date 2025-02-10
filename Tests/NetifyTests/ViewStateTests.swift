import XCTest
@testable import Netify

final class ViewStateTests: XCTestCase {
    
    func testViewStateError() {
        let error = NetworkError.unauthorized(statusCode: 401)
        let state = ViewState.error(error)
        
        if case let ViewState.error(receivedError) = state {
            switch receivedError {
            case .unauthorized(let statusCode):
                XCTAssertEqual(statusCode, 401)
            default:
                XCTFail("Ожидалась ошибка unauthorized, получено: \(receivedError)")
            }
        } else {
            XCTFail("Ожидалось состояние error")
        }
    }
    
    func testViewStateTransitions() {
        var state = ViewState.initial
        XCTAssertEqual("\(state)", "initial")
        
        state = .loading
        XCTAssertEqual("\(state)", "loading")
        
        state = .loaded
        XCTAssertEqual("\(state)", "loaded")
    }
}
