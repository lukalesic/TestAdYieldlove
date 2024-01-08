import Foundation

public protocol MonitoringReporter {
    func report(sessions: [String])
}

public class HttpMonitoringReporter: MonitoringReporter {

    public static let httpMethod = "POST"
    public static let apiKeyHeaderName = "X-API-Key"
    public static let contentType = "application/json; charset=UTF-8"
    public static let contentTypeHeaderName = "Content-Type"

    private let appName: String
    private let sdkVersion: String
    private let apiKey: String
    private let url: URL?
    private let urlSession: URLSessionProtocol

    public init(appName: String, sdkVersion: String, apiKey: String, url: String, urlSession: URLSessionProtocol = URLSession.shared) {
        self.appName = appName
        self.sdkVersion = sdkVersion
        self.apiKey = apiKey
        self.url = URL(string: url)
        self.urlSession = urlSession
    }

    public func report(sessions: [String]) {
        let body = createRequestBody(sessions: sessions)
        if let request = try? createRequest(body: body) {
            urlSession.dataTask(with: request)
        }
    }

    private func createRequest(body: String) throws -> URLRequest {
        guard let monitoringUrl = url else {
            throw MonitoringError.invalidMonitoringUrl
        }
        var request = URLRequest(url: monitoringUrl)
        request.httpMethod = Self.httpMethod
        request.setValue(Self.contentType, forHTTPHeaderField: Self.contentTypeHeaderName)
        request.setValue(apiKey, forHTTPHeaderField: Self.apiKeyHeaderName)
        request.httpBody = body.data(using: .utf8)
        return request
    }

    private func createRequestBody(sessions: [String]) -> String {
        let osVersion = getOSVersion()
        let sessionsJoined = sessions.joined(separator: ",")
        return "{\"appName\":\"\(appName)\",\"os\":\"\(osVersion)\",\"sessions\":[\(sessionsJoined)]}"
    }

    private func getOSVersion() -> String {
        let iosVersion = ProcessInfo.processInfo.operatingSystemVersionString
        return "iOS \(iosVersion) (SDK \(sdkVersion))"
    }

}
