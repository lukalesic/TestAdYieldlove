import GoogleMobileAds

protocol ReferenceHolder: AnyObject {
    var id: Int { get }
    var areReferencesReleased: Bool { get }
    var areReferencedObjectsStillInMemory: Bool { get }
}

class YLReferenceHolder: ReferenceHolder {
    
    private static var lastId = 0
    
    let id: Int
    private let bannerView: GAMBannerView
    private let delegate: AdDelegate
    
    init(bannerView: GAMBannerView, delegate: AdDelegate) {
        self.bannerView = bannerView
        self.delegate = delegate
        self.id = Self.lastId
        Self.lastId += 1
    }
    
    var areReferencesReleased: Bool {
        if delegate.isPublisherDelegateNil() {
            return true
        }
        if hasPublisherClearedDelegateFromAd {
            return true
        }
        return false
    }
    
    var areReferencedObjectsStillInMemory: Bool {
        return !areReferencesReleased
    }
    
    private var hasPublisherClearedDelegateFromAd: Bool {
        if let ylBannerView = delegate.ylBannerView, ylBannerView.bannerView.delegate == nil {
            return true
        }
        return false
    }

}
