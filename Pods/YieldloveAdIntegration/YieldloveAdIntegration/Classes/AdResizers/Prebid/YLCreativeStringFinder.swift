// Adapted from https://github.com/prebid/prebid-mobile-ios

import Foundation
import WebKit

typealias FailHandler = (YLCreativeStringFinderError) -> Void

final class YLCreativeStringFinder: NSObject {

    private static let innerHtmlScript = "document.body.innerHTML"
    
    private override init() {}
    
    @objc
    static func find(_ adView: UIView, _ stringToFind: String?, success: @escaping (Bool) -> Void, failure: @escaping (Error) -> Void) {
        
        if stringToFind == nil {
            warnAndTriggerFailure(CreativeStringFinderErrorFactory.missingInput, failure: failure)
            return
        }
        
        let view = self.findView(adView) { (subView) -> Bool in
            return isWKWebView(subView)
        }
        
        if let wkWebView = view as? WKWebView, let safeString = stringToFind {
            self.findStringInWebView(wkWebView: wkWebView, str: safeString, success: success, failure: failure)
        } else {
            warnAndTriggerFailure(CreativeStringFinderErrorFactory.noWKWebView, failure: failure)
        }
    }
    
    static func triggerSuccess(stringFound: Bool, success: @escaping (Bool) -> Void) {
        success(stringFound)
    }
    
    static func warnAndTriggerFailure(_ error: YLCreativeStringFinderError, failure: @escaping (YLCreativeStringFinderError) -> Void) {
        if Yieldlove.instance.debug {
            print(error.localizedDescription)
        }
        failure(error)
    }
    
    static func findView(_ view: UIView, closure: (UIView) -> Bool) -> UIView? {
        if closure(view) {
            return view
        } else {
            return recursivelyFindView(view, closure: closure)
        }
    }
    
    static func recursivelyFindView(_ view: UIView, closure: (UIView) -> Bool) -> UIView? {
        for subview in view.subviews {
            
            if closure(subview) {
                return subview
            }
            
            if let result = recursivelyFindView(subview, closure: closure) {
                return result
            }
        }
        
        return nil
    }
    
    static func findStringInWebView(wkWebView: WKWebView, str: String, success: @escaping (Bool) -> Void, failure: @escaping FailHandler) {
        let htmlScript = YLCreativeStringFinder.innerHtmlScript
        wkWebView.evaluateJavaScript(htmlScript, completionHandler: { value, error in
            if let safeToManipulateError = error {
                let description = safeToManipulateError.localizedDescription
                let wvError = CreativeStringFinderErrorFactory.getWkWebViewFailedError(message: description)
                self.warnAndTriggerFailure(wvError, failure: failure)
                return
            }
            self.findStringInHtml(body: value as? String, str: str, success: success, failure: failure)
        })
        
    }
    
    static func findStringInHtml(body: String?, str: String, success: @escaping (Bool) -> Void, failure: @escaping FailHandler) {
        let result = findStringInHtml(body: body, str: str)
        
        if result.stringFound {
            triggerSuccess(stringFound: result.stringFound, success: success)
        } else if let error = result.error {
            warnAndTriggerFailure(error, failure: failure)
        } else {
            warnAndTriggerFailure(CreativeStringFinderErrorFactory.unspecified, failure: failure)
        }
    }
    
    static func findStringInHtml(body: String?, str: String) -> (stringFound: Bool, error: YLCreativeStringFinderError?) {
        guard let htmlBody = body, !htmlBody.isEmpty else {
            return (false, CreativeStringFinderErrorFactory.noHtml)
        }

        if htmlBody.contains(str) {
            return (true, nil)
        } else {
            return (false, CreativeStringFinderErrorFactory.notPrebidOrCriteoAd)
        }
    }
    
    static func isWKWebView(_ view: UIView) -> Bool {
        return view is WKWebView
    }

}

// It is not possible to use Enum because of compatibility with Objective-C
final class CreativeStringFinderErrorFactory {
    
    private init() {}
    
    // MARK: - Platform's errors
    static let unspecifiedCode = 101
    
    // MARK: - common errors
    static let noWKWebViewCode = 111
    static let wkWebViewFailedCode = 126
    static let noHtmlCode = 130
    static let missingInputCode = 140
    static let notPrebidOrCriteoAdCode = 150

    // MARK: - fileprivate and private zone
    fileprivate static let unspecified = getUnspecifiedError()
    fileprivate static let noWKWebView = getNoWKWebViewError()
    fileprivate static let noHtml = getNoHtmlError()
    fileprivate static let missingInput = getMissingInputError()
    fileprivate static let notPrebidOrCriteoAd = getNotPrebidOrCriteoAdError()
    
    private static func getUnspecifiedError() -> YLCreativeStringFinderError {
        return getError(code: unspecifiedCode, description: "Unspecified error")
    }
    
    private static func getNoWKWebViewError() -> YLCreativeStringFinderError {
        return getError(code: noWKWebViewCode, description: "The view doesn't include WKWebView")
    }
    
    fileprivate static func getWkWebViewFailedError(message: String) -> YLCreativeStringFinderError {
        return getError(code: wkWebViewFailedCode, description: "WKWebView error:\(message)")
    }
    
    private static func getNoHtmlError() -> YLCreativeStringFinderError {
        return getError(code: noHtmlCode, description: "The WebView doesn't have HTML")
    }
    
    private static func getMissingInputError() -> YLCreativeStringFinderError {
        return getError(code: missingInputCode, description: "String to search for was not passed")
    }
    
    private static func getNotPrebidOrCriteoAdError() -> YLCreativeStringFinderError {
        return getError(code: notPrebidOrCriteoAdCode, description: "HTML does not contain string. Not a Prebid or Criteo ad.")
    }
    
    private static func getError(code: Int, description: String) -> YLCreativeStringFinderError {
        return YLCreativeStringFinderError(domain: "com.prebidmobile.ios", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }
}
