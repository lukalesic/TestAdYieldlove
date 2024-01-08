import PromiseKit
import GoogleMobileAds

class AdDelegatePromiseBridge: NSObject, GADBannerViewDelegate {
    
    private(set) var promise: Promise<YLBannerView>
    private var resolver: Resolver<YLBannerView>
    
    override init() {
        let (promise, resolver) = Promise<YLBannerView>.pending()
        self.promise = promise
        self.resolver = resolver
    }
    
    func fulfill(value: YLBannerView) {
        resolver.fulfill(value)
    }
    
    func reject(error: YLError) {
        resolver.reject(error)
    }
    
    func replacePromise() {
        let (promise, resolver) = Promise<YLBannerView>.pending()
        self.promise = promise
        self.resolver = resolver
    }

}
