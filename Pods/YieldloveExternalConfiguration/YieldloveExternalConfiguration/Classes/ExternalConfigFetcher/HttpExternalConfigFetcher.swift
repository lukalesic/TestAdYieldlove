import Foundation
import PromiseKit

enum HttpExternalConfigFetcherError : LocalizedError {
    case notSuccessfulStatus(statusCode: String)

    var errorDescription: String? {
        switch self {
        case .notSuccessfulStatus(let statusCode):
            return "External reporter request status is not succesful, http status code: \(statusCode)"
        }
    }
}

class HttpExternalConfigFetcher: ConfigFetcher {
    
    private var requestSender: RequestSender
    private var promiseOfResponse: Promise<String>?
    
    init(requestSender: RequestSender) {
        self.requestSender = requestSender
    }
    
    func fetch(url: String) -> Promise<String> {
        if let promiseMadeEarlier = promiseOfResponse {
            if promiseMadeEarlier.isResolved {
                promiseOfResponse = nil
            }
        }
        
        if let promiseMadeEarlier = promiseOfResponse {
            return promiseMadeEarlier
        } else {
            let response = request(url: url)
            promiseOfResponse = response
            return response
        }
    }
    
    private func request(url: String) -> Promise<String> {
        let promise = requestSender.get(url: url)
            .map(handleResponse)
        promise.catch { _ in
            self.handleError()
        }
        return promise
    }
    
    private func handleResponse(senderResponse: RequestSenderResponse) throws -> String {
        try self.assertResponseOk(response: senderResponse)
        
        if let url = senderResponse.response?.url {
            Logger.debug(message: "External config from \(url) was fetched")
        }

        guard let responseData = senderResponse.data else {
            throw ConfigurationFetcherError.responseContainsNoData
        }
        
        guard let json = String.init(data: responseData, encoding: .utf8) else {
            throw ConfigurationFetcherError.unableToReadResponseData
        }
        return json
    }
    
    private func assertResponseOk(response: RequestSenderResponse) throws {
        if let httpResponse = response.response as? HTTPURLResponse {
            let code = httpResponse.statusCode
            if !response.isSuccessfulHttpResponse() {
                Logger.debug(message: "External config fetcher has not succeed with status code: \(String(code))")

                throw HttpExternalConfigFetcherError.notSuccessfulStatus(statusCode: String(code))
            } else {
                print("External config http response status validation successful")
            }
        }
    }
    
    private func handleError() {
        Logger.debug(message: "Http External Config Fetcher method fetch failure")
    }
}
