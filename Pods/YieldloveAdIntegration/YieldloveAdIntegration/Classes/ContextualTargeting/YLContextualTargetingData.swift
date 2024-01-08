import GoogleMobileAds

class YLContextualTargetingData: NSObject {

    var idfa: String
    var contentURL: String
    
    init(idfa: String, contentURL: String) {
        self.idfa = idfa
        self.contentURL = contentURL
    }
}
