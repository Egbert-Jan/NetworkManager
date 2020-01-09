import Foundation

open class NetworkManager {
    
    public init() { }
    
    @discardableResult
    open func request(target: NMTarget, completion: @escaping ((Result<NMResponse, Error>) -> Void)) -> URLSessionDataTask {

        var request = URLRequest(url:
            target.baseUrl.appendingPathComponent(target.path))
        request.httpMethod = target.method.rawValue

        switch target.task {
        case .plainRequest:
            break
        case .urlParameters(let parameters):
            
            var urlcomp = URLComponents(string: request.url!.absoluteString)
            urlcomp?.queryItems = parameters.compactMap {
                URLQueryItem(name: $0, value: "\($1)")
            }
            
            request.url = urlcomp?.url
        case .bodyParameters(let body):
            request.httpBody = try! JSONSerialization.data(
                withJSONObject: body, options: [])
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data, let response = response {
                completion(.success(NMResponse(data: data, response: response)))
            } else {
                completion(.failure(NMError.emptyResponseOrData))
            }
        }
        
        dataTask.resume()
        
        return dataTask
    }
}

public protocol NMTarget {
    var baseUrl: URL { get }
    var path: String { get }
    var method: NMMethod { get }
    var task: NMTask { get }
}

public enum NMMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum NMTask {
    case plainRequest
    case urlParameters([String: Any])
    case bodyParameters([String: Any])
//    case bodyAndUrlParameters
}

public struct NMResponse {
    public var data: Data
    public var response: URLResponse
    
    public func getDecodedObject<T: Decodable>(object: T.Type) -> T? {
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
