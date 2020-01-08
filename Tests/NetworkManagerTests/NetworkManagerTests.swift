import XCTest
@testable import NetworkManager

final class NetworkManagerTests: XCTestCase {
    
    var networkManager = NetworkManager()
    
    func testRawGet() {
        let exp = expectation(description: "succesfull response")
        
        networkManager.request(target: PostmanEcho.postmanGETTest) { result in
            switch result {
            case .success(let response):
                XCTAssert(response.data.count > 0)
                exp.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRawPost() {
        let exp = expectation(description: "succesfull response")
        
        networkManager.request(target: PostmanEcho.postmanPOSTTest) { result in
            switch result {
            case .success(let response):
                XCTAssert(response.data.count > 0)
                exp.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRawPut() {
        let exp = expectation(description: "succesfull response")
        
        networkManager.request(target: PostmanEcho.postmanPUTTest) { result in
            switch result {
            case .success(let response):
                XCTAssert(response.data.count > 0)
                exp.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRawDelete() {
        let exp = expectation(description: "succesfull response")
        
        networkManager.request(target: PostmanEcho.postmanDELETETest) { result in
            switch result {
            case .success(let response):
                XCTAssert(response.data.count > 0)
                exp.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    static var allTests = [
        ("testRawGet", testRawGet),
        ("testRawPost", testRawPost),
        ("testRawPut", testRawPut),
        ("testRawDelete", testRawDelete)
    ]
}


enum PostmanEcho: NMTarget {
    case postmanGETTest
    case postmanPOSTTest
    case postmanPUTTest
    case postmanDELETETest
    
    var baseUrl: URL {
        return URL(string: "https://postman-echo.com/")!
    }
    
    var path: String {
        switch self {
        case .postmanGETTest: return "get"
        case .postmanPOSTTest: return "post"
        case .postmanPUTTest: return "put"
        case .postmanDELETETest: return "delete"
        }
    }
    
    var method: NMMethod {
        switch self {
        case .postmanGETTest: return .get
        case .postmanPOSTTest: return .post
        case .postmanPUTTest: return .put
        case .postmanDELETETest: return .delete
        }
    }
}
