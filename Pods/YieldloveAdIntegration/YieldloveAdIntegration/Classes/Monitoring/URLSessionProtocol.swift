import Foundation

public protocol URLSessionProtocol {
    func dataTask(with request: URLRequest)
}

extension URLSession: URLSessionProtocol {
    public func dataTask(with request: URLRequest) {
        let task = self.dataTask(with: request) { _, _, _ in
        }
        task.resume()
    }
}
