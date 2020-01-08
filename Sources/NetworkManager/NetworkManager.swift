import Foundation

class NetworkManager {
    
    func request(target: NMTarget, completion: @escaping ((Result<NMResponse, Error>) -> Void)) {

        var request = URLRequest(url:
            target.baseUrl.appendingPathComponent(target.path))
        request.httpMethod = target.method.rawValue
        
        if target.method != .get {
            let body: [String: Any] = ["hoi": "Hello", "age": 5]
            request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let data = data, let response = response {
                completion(.success(NMResponse(data: data, response: response)))
            } else {
                completion(.failure(NMError.emptyResponseOrData))
            }
        }
        
        dataTask.resume()
    }
}

protocol NMTarget {
    var baseUrl: URL { get }
    var path: String { get }
    var method: NMMethod { get }
}

enum NMMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NMTask {
    case plainRequest
    case urlParameters([String: Any])
    case bodyParameters([String: Any])
//    case bodyAndUrlParameters
}

struct NMResponse {
    var data: Data
    var response: URLResponse
    
    func getDecodedObject<T: Decodable>(object: T.Type) -> T? {
        do {
            return try JSONDecoder().decode(object, from: data)
        } catch {
            return nil
        }
    }
}

enum NMError: Error {
    case emptyResponseOrData
}
