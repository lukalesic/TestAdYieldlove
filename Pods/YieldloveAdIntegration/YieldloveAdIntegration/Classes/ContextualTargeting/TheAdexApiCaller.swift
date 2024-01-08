import PromiseKit
import YieldloveExternalConfiguration

protocol AdexApiCaller {
    func submit(data: YLContextualTargetingData) -> Promise<Void>
}

class TheAdexApiCaller: AdexApiCaller {
    public static let httpMethod = "GET"
    private static let queueLabel = "contextualTargeting"
    private let sender: RequestSender
    
    init(sender: RequestSender = HttpRequestSender(dispatchQueue: DispatchQueue(label: queueLabel, qos: .utility))) {
        self.sender = sender
    }
    
    func submit(data: YLContextualTargetingData) -> Promise<Void> {
        if let theAdexRequestUrl = YLAdexUrlBuilder.buildTheAdexRequestUrl(data: data) {
            return executeRequest(url: theAdexRequestUrl)
        }
        return Promise { seal in
            seal.reject(ContextualTargetingError.unableToReportUrlToTheAdex)
        }
    }

    private func executeRequest(url: String) -> Promise<Void> {
        let promise = sender.get(url: url)
            .map { _ in
                return Void()
            }
        promise.catch { error in
            self.handleError(err: error, url: url)
        }
        return promise
    }
    
    private func handleError(err: Error, url: String) {
        if Yieldlove.instance.debug {
            print("\(Date()): contextualTargeting request \(url) failure")
        }
    }
}
