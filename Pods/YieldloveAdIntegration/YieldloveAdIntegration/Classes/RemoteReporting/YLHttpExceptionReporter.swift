import Foundation
import PromiseKit
import YieldloveExternalConfiguration

struct ReportData {
    var os: String
    var appName: String
}

protocol ExceptionReporter {
    @discardableResult func report(err: Error) -> Promise<Void>
}

enum YLHttpExceptionReporterError: LocalizedError {
    case notSuccessfulStatus(statusCode: String)

    var errorDescription: String? {
        switch self {
        case .notSuccessfulStatus(let statusCode):
            return "Exception reporter request status is not successful, http status code: \(statusCode)"
        }
    }
}

class YLHttpExceptionReporter: ExceptionReporter {
    private var remoteServiceUrl: String
    private var remoteServiceApiKey: String
    private var requestSender: RequestSender

    init(requestSender: RequestSender = HttpRequestSender(),
         remoteServiceUrl: String,
         remoteServiceApiKey: String) {

        self.requestSender = requestSender
        self.remoteServiceUrl = remoteServiceUrl
        self.remoteServiceApiKey = remoteServiceApiKey
    }

    @discardableResult
    func report(err: Error) -> Promise<Void> {
        let body: Data? = try? createDataBody(err: err)
        let headers = getHeaders()
        
        let promise = requestSender.post(url: remoteServiceUrl, body: body, headers: headers)
            .map { response in
                try self.handleResponse(response: response, reportedError: err)
            }
        promise.catch(self.handleError)
        return promise
    }
    
    private func handleResponse(response: RequestSenderResponse, reportedError: Error) throws {
        try self.validateResponse(response: response)
        if Yieldlove.instance.debug {
            print("Error \(String(describing: reportedError)) was sent into remote reporting")
        }
    }
        
    private func validateResponse(response: RequestSenderResponse) throws {
        if let httpResponse = response.response as? HTTPURLResponse {
            let code = httpResponse.statusCode
            if !response.isSuccessfulHttpResponse() {
                if Yieldlove.instance.debug {
                    print("\(Date()): Remote error reporting has not succeed with status code: \(String(code))")
                }
                throw YLHttpExceptionReporterError.notSuccessfulStatus(statusCode: String(code))
            }
        }
    }
    
    private func handleError(error: Error) {
        if Yieldlove.instance.debug {
            print("\(Date()): Remote error reporting failed \(String(describing: error))")
        }
    }

    private func getHeaders() -> [String: String] {
        ["X-API-Key": remoteServiceApiKey]
    }

    private func createDataBody(err: Error) throws -> Data {
        var data: [String: String] = [:]

        if let localizedError = err as? LocalizedError {
            let message: String = localizedError.errorDescription != nil ? localizedError.errorDescription! : "message is not configured"
            data = [
                "message": message,
                "exceptionType": String(describing: err)
            ]
        } else {
            data = [
                "exceptionType": String(describing: err)
            ]
        }
        
        let dictionaryData: [String: Any] = [
            "os": getOSInfo(),
            "device": getDevice(),
            "appName": getAppName(),
            "sdkVersionName": getSdkVersion(),
            "report": [
                "type": "error",
                "data": data
            ]
        ]

        return try JSONSerialization.data(withJSONObject: dictionaryData)
    }

    private func getSdkVersion() -> String {
        YLConstants.version
    }

    private func getAppName() -> String {
        guard let appName = ExternalConfigurationManagerBuilder.instance.appName else {
            return "App name not set"
        }
        return appName
    }

    private func getDevice() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }

    private func getOSInfo() -> String {
        let os = ProcessInfo.processInfo.operatingSystemVersion
        return "iOS " + String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
}
