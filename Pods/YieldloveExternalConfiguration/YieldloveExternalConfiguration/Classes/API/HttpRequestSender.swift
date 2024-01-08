import Foundation
import PromiseKit

public typealias ReqSenderCompletionHandler = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

public struct RequestSenderResponse {

    public init(data: Data?, response: URLResponse?) {
        self.data = data
        self.response = response
    }

    public let data: Data?
    public let response: URLResponse?
    
    public func isSuccessfulHttpResponse() -> Bool {
        if let httpResponse = response as? HTTPURLResponse {
            let code = httpResponse.statusCode
            return (200...299).contains(code)
        }
        return false
    }
}

public enum RequestSenderError: LocalizedError {
    case invalidRequestUrl(invalidUrl: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidRequestUrl(let invalidUrl):
            return "Request URL '\(invalidUrl)' is not valid"
        }
    }
}

public protocol RequestSender {
    func get(url: String, headers: [String: String]) -> Promise<RequestSenderResponse>
    func post(url: String, body: Data?, headers: [String: String]) -> Promise<RequestSenderResponse>
}

public extension RequestSender {
    func get(url: String, headers: [String: String] = [:]) -> Promise<RequestSenderResponse> {
        self.get(url: url, headers: headers)
    }
    func post(url: String, body: Data?, headers: [String: String] = [:]) -> Promise<RequestSenderResponse> {
        self.post(url: url, body: body, headers: headers)
    }
}

public class HttpRequestSender: RequestSender {
    
    public static let httpMethodGet = "GET"
    public static let httpMethodPost = "POST"
    
    private let dispatchQueue: DispatchQueue
    private let urlSession: URLSession

    public init(dispatchQueue: DispatchQueue = DispatchQueue.global(qos: .default), configuration: URLSessionConfiguration = .default) {
        self.dispatchQueue = dispatchQueue
        self.urlSession = URLSession(configuration: configuration)
    }
    
    public func get(url: String, headers: [String: String] = [:]) -> Promise<RequestSenderResponse> {
        return Promise { seal in
            dispatchQueue.async {
                if let request = try? self.createGetRequest(url: url, headers: headers) {
                    self.urlSession.dataTask(with: request) { data, response, error in
                        if let err = error {
                            seal.reject(err)
                        } else {
                            let httpResponse = RequestSenderResponse(data: data, response: response)
                            seal.fulfill(httpResponse)
                        }
                    }.resume()
                }
            }
        }
    }
    
    public func post(url: String, body: Data?, headers: [String: String] = [:]) -> Promise<RequestSenderResponse> {
        return Promise { seal in
            dispatchQueue.async {
                if let request = try? self.createPostRequest(url: url, body: body, headers: headers) {
                    self.urlSession.dataTask(with: request) { data, response, error in
                        if let err = error {
                            seal.reject(err)
                        } else {
                            let httpResponse = RequestSenderResponse(data: data, response: response)
                            seal.fulfill(httpResponse)
                        }
                    }.resume()
                }
            }
        }
    }
    
    private func createPostRequest(url: String, body: Data?, headers: [String: String]) throws -> URLRequest {
        var request = try self.createBasicRequest(method: HttpRequestSender.httpMethodPost, url: url)
        
        if let safeBody = body {
            request.httpBody = safeBody
        }
        
        return setHeaders(request: request, headers: headers)
    }
    
    private func setHeaders(request: URLRequest, headers: [String: String]) -> URLRequest {
        var enrichedRequest = request
        for (key, value) in headers {
            enrichedRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        return enrichedRequest
    }
    
    private func createGetRequest(url: String, headers: [String: String]) throws -> URLRequest {
        let request = try createBasicRequest(url: url)
        return setHeaders(request: request, headers: headers)
    }
    
    private func createBasicRequest(method: String = HttpRequestSender.httpMethodGet, url: String) throws -> URLRequest {
        guard let url = URL(string: url) else {
            throw RequestSenderError.invalidRequestUrl(invalidUrl: url)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }
}
