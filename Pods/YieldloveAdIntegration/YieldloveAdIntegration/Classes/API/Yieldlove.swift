import Foundation
import GoogleMobileAds
import PromiseKit
import YieldloveExternalConfiguration

public typealias GetAdSizesCompletion = (_ adSizes: NSArray, _ error: Error?) -> Void
public typealias InterstitialCompletion = (_ ad: GAMInterstitialAd?, _ error: Error?) -> Void
public typealias RewardedAdCompletion = (_ ad: GADRewardedAd?, _ error: Error?) -> Void

@objc public class Yieldlove: NSObject {

    @objc public static let instance = Yieldlove()
    @objc public var adRequest = GAMRequest()
    @objc public var developerModeEnabled = false
    
    var debug = false

    private static var config: Config?

    private let configurationManager: ConfigurationManager

    @objc public class func setup(appName: String) {
        Yieldlove.setupEnvironment(appName: appName)
    }
    
    class func setupEnvironment(appName: String, configProvider: Config.Type = YLConfig.self) {
        ExternalConfigurationManagerBuilder.instance.appName = appName
        if Yieldlove.config == nil {
            Yieldlove.config = configProvider.getProductionConfig(appName: appName)
        }
    }

    override private init() {
        guard let config = Yieldlove.config else {
            fatalError("Error - you must call setup before accessing Yieldlove.instance")
        }
        self.configurationManager = config.configurationManager
        super.init()
        GADMobileAds.sharedInstance().start()
    }

    func getConfig() -> Config {
        guard let config = Yieldlove.config else {
            fatalError("Error - you must call setup before accessing Yieldlove.instance")
        }
        return config
    }
    
    @objc public func clearConfigurationCache() {
        self.configurationManager.clearConfigurationCache()
    }

    @objc public func enableDebug(isEnabled: Bool) {
        Yieldlove.instance.debug = isEnabled
        ExternalConfigurationManagerBuilder.instance.debug = isEnabled
    }

    @objc public func bannerAd(adSlotId: String, viewController: UIViewController, delegate: YLBannerViewDelegate) {
        let config = getConfig()
        let bannerConfiguration = YLBannerConfiguration(adSlotId, config, viewController, delegate)
        YLBannerLoader(bannerConfiguration: bannerConfiguration).loadBanner()
    }
    
    // GAMRequest is optional to get rid of a warning in Objective-C apps
    // which appears when nil is passed to methods that do not accept nil
    @objc public func interstitialAd(adSlotId: String, completion: @escaping InterstitialCompletion, request: GAMRequest? = GAMRequest()) {
        let config = getConfig()
        YLInterstitial(config: config, completion: completion, request: request ?? GAMRequest())
                .load(adSlotId: adSlotId)
    }
    
    @objc public func rewardedAd(adSlotId: String, completion: @escaping RewardedAdCompletion, request: GAMRequest? = GAMRequest()) {
        let config = getConfig()
        YLRewardedAd(config: config, completion: completion, request: request ?? GAMRequest())
            .load(adSlotId: adSlotId)
    }

    @objc public func resizeBanner(banner: YLBannerView, handler: (() -> Void)? = {}) {
        YLAdResizer().resizeAd(banner: banner, completion: handler)
    }

    @objc public func getAdSizes(adSlotId: String, completion: @escaping GetAdSizesCompletion) {
        self.configurationManager
            .getAdUnitData(publisherAdSlot: adSlotId, adType: .bannerAd)
            .map(YLAdUnitDataTransformer.transformBannerAdUnitData)
            .map { adUnitData in
                completion(YLAdSizeCollection(sizes: adUnitData.bannerSizes).getSizes(), nil)
            }.catch { error in
                completion([] as NSArray, AdSlotConfigurationError(error))
            }
    }

}
