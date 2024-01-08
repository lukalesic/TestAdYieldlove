import GoogleMobileAds

struct YLBannerConfiguration {
    
    let adSlotId: String
    let config: Config
    let viewController: UIViewController
    let publisherDelegate: YLBannerViewDelegate
    
    init(_ adSlotId: String, _ config: Config, _ viewController: UIViewController, _ publisherDelegate: YLBannerViewDelegate) {
        self.adSlotId = adSlotId
        self.config = config
        self.viewController = viewController
        self.publisherDelegate = publisherDelegate
    }
    
}
