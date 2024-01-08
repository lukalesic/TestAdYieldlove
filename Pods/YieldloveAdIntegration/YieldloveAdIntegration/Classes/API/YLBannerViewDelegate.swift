import GoogleMobileAds
// Adapted from GADBannerViewDelegate

@objc public protocol YLBannerViewDelegate {

    /// Tells the delegate that an ad request successfully received an ad. The delegate may want to add
    /// the banner view to the view hierarchy if it hasn't been added yet.
    @objc optional func bannerViewDidReceiveAd(_ bannerView: YLBannerView)

    /// Tells the delegate that an ad request failed. The failure is normally due to network
    /// connectivity or ad availablility (i.e., no fill).
    @objc optional func bannerView(_ bannerView: YLBannerView, didFailToReceiveAdWithError error: Error)
    
    /// Tells the delegate that a full screen view will be presented in response to the user clicking on
    /// an ad. The delegate may want to pause animations and time sensitive interactions.
    @objc optional func bannerViewWillPresentScreen(_ bannerView: YLBannerView)

    /// Tells the delegate that the full screen view will be dismissed.
    @objc optional func bannerViewWillDismissScreen(_ bannerView: YLBannerView)

    /// Tells the delegate that the full screen view has been dismissed. The delegate should restart
    /// anything paused while handling adViewWillPresentScreen:.
    @objc optional func bannerViewDidDismissScreen(_ bannerView: YLBannerView)
    
    @objc optional func bannerViewDidStartLoadingAd()
    
    @objc optional func getGAMRequest() -> GAMRequest
}
