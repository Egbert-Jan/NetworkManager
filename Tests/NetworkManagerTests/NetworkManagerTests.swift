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
    
    func testGetWithParameters() {
        let exp = expectation(description: "succesfull response")
        
        networkManager.request(target: PostmanEcho.postmanGETTestWithParameters(amount: 3, page: 8, name: "Egbert")) { result in
            switch result {
            case .success(let response):
                let data = try! JSONSerialization.jsonObject(with: response.data, options: []) as! [String: Any]
                XCTAssertNotNil(data["args"])
                XCTAssert((data["url"] as! String).contains("page"))
                XCTAssert((data["url"] as! String).contains("amount"))
                XCTAssert((data["url"] as! String).contains("name"))
                XCTAssert((data["url"] as! String).contains("8"))
                XCTAssert((data["url"] as! String).contains("3"))
                XCTAssert((data["url"] as! String).contains("Egbert"))
                XCTAssert((data["url"] as! String).contains("?"))
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
    
    func testPostWithData() {
        let exp = expectation(description: "succesfull response")
        
        networkManager.request(target: PostmanEcho.postmanPOSTTestWithData(name: "Egbert", password: "YesMyPassword")) { result in
            switch result {
            case .success(let response):
                let data = try! JSONSerialization.jsonObject(with: response.data, options: [])
                print(data)
                let obj = data as! [String: Any]
                let json = obj["json"] as! [String: Any]
//                XCTAssertEqual(json["name"] as! String, "Egbert")
//                XCTAssertEqual(json["password"] as! String, "YesMyPassword")
                XCTAssert(response.data.count > 0)
                XCTAssert(json.count > 0)
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
    
    func testCancel() {
        let exp = expectation(description: "no response")
        
        let task = networkManager.request(target: PostmanEcho.postmanGETTest) { result in
            switch result {
            case .success:
                XCTFail("Should not get a response")
            case .failure(let error):
                XCTAssertNotNil(error, "Error should be cancelled")
                exp.fulfill()
            }
        }
        
        task.cancel()
        
        waitForExpectations(timeout: 0.05, handler: nil)
    }
    
    static var allTests = [
        ("testRawGet", testRawGet),
        ("testGetWithParameters", testGetWithParameters),
        ("testRawPost", testRawPost),
        ("testPostWithData", testPostWithData),
        ("testRawPut", testRawPut),
        ("testRawDelete", testRawDelete),
        ("testCancel", testCancel)
    ]
}


enum PostmanEcho: NMTarget {
    case postmanGETTest
    case postmanGETTestWithParameters(amount: Int, page: Int, name: String)
    case postmanPOSTTest
    case postmanPOSTTestWithData(name: String, password: String)
    case postmanPUTTest
    case postmanDELETETest
    
    var baseUrl: URL {
        return URL(string: "https://postman-echo.com/")!
    }
    
    var path: String {
        switch self {
        case .postmanGETTest,
             .postmanGETTestWithParameters: return "get"
        case .postmanPOSTTest,
             .postmanPOSTTestWithData: return "post"
        case .postmanPUTTest: return "put"
        case .postmanDELETETest: return "delete"
        }
    }
    
    var method: NMMethod {
        switch self {
        case .postmanGETTest,
             .postmanGETTestWithParameters: return .get
        case .postmanPOSTTest,
             .postmanPOSTTestWithData: return .post
        case .postmanPUTTest: return .put
        case .postmanDELETETest: return .delete
        }
    }
    
    var task: NMTask {
        switch self {
        case .postmanGETTest,
             .postmanPOSTTest,
             .postmanPUTTest,
             .postmanDELETETest:
            return .plainRequest
            
        case let .postmanGETTestWithParameters(amount, page, name):
            let data: [String: Any] = ["amount": amount, "page": page, "name": name]
            return .urlParameters(data)
            
        case let .postmanPOSTTestWithData(name, password):
            let body: [String: Any] = ["name": name, "password": password]
            return .bodyParameters(body)
        }
    }
}
