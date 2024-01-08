import GoogleMobileAds
import PromiseKit

struct GamRequestData {
    var adUnitData: YLAdUnitData
    var gamRequest: GAMRequest
    var publisherViewController: UIViewController
    var publisherDelegate: YLBannerViewDelegate?
}

typealias GamInstlRequestData = (adUnitData: YLAdUnitData,
                                 gamRequest: GAMRequest)

typealias RewardedRequestData = (adUnitData: YLAdUnitData,
                                      gamRequest: GAMRequest)

typealias RewardedCompletion = GADRewardedAdLoadCompletionHandler
typealias InstlCompletion = GAMInterstitialAdLoadCompletionHandler

protocol GamAdLoader {
    @discardableResult
    func loadBanner(gamRequestData: GamRequestData, ylBanner: YLBanner) -> Promise<YLBannerView>
    func loadRefreshableBanner(gamRequestData: GamRequestData, ylBanner: YLRefreshableBanner) -> Promise<YLBannerView>
    func refreshBanner(gamRequestData: GamRequestData, ylBannerView: YLBannerView) -> Promise<YLBannerView>
    @discardableResult
    func loadInterstitial(gamRequestData: GamInstlRequestData, timeEventRecorder: TimeEventRecorder) -> Promise<GAMInterstitialAd>
    @discardableResult
    func loadRewardedAd(gamRequestData: RewardedRequestData, timeEventRecorder: TimeEventRecorder) -> Promise<GADRewardedAd>
}

class YLGamAdLoader: GamAdLoader {

    private let bannerViewFactory: GamBannerViewFactory
    private let gamInterstitialProvider: GAMInterstitialAd.Type
    private let gamRewardedAdProvider: GADRewardedAd.Type

    init(bannerViewFactory: GamBannerViewFactory,
         gamInterstitialProvider: GAMInterstitialAd.Type = GAMInterstitialAd.self,
         gamRewardedAdProvider: GADRewardedAd.Type = GADRewardedAd.self) {
        self.bannerViewFactory = bannerViewFactory
        self.gamInterstitialProvider = gamInterstitialProvider
        self.gamRewardedAdProvider = gamRewardedAdProvider
    }

    func loadBanner(gamRequestData: GamRequestData, ylBanner: YLBanner) -> Promise<YLBannerView> {
        let adDelegate = YLAdDelegate(gamRequestData: gamRequestData, timeEventRecorder: ylBanner.timeEventRecorder)
        let bannerView = bannerViewFactory.makeGAMBannerView(adUnitData: gamRequestData.adUnitData, delegate: adDelegate)

        let referenceHolder = YLReferenceHolder(bannerView: bannerView, delegate: adDelegate)
        keepReference(referenceHolder, ylAd: ylBanner)
        
        recordGamRequest(timeEventRecorder: ylBanner.timeEventRecorder)
        bannerView.load(gamRequestData.gamRequest)
        return adDelegate.promise
    }
    
    func loadRefreshableBanner(gamRequestData: GamRequestData, ylBanner: YLRefreshableBanner) -> Promise<YLBannerView> {
        let adDelegate = YLAdDelegate(gamRequestData: gamRequestData, timeEventRecorder: ylBanner.timeEventRecorder)
        let bannerView = bannerViewFactory.makeGAMBannerView(adUnitData: gamRequestData.adUnitData, delegate: adDelegate)

        let referenceHolder = YLReferenceHolder(bannerView: bannerView, delegate: adDelegate)
        startRefreshTimer(gamRequestData: gamRequestData, ylBanner: ylBanner, referenceHolder: referenceHolder)
        keepReference(referenceHolder, ylAd: ylBanner)
        
        recordGamRequest(timeEventRecorder: ylBanner.timeEventRecorder)
        bannerView.load(gamRequestData.gamRequest)
        return adDelegate.promise
    }
    
    func refreshBanner(gamRequestData: GamRequestData, ylBannerView: YLBannerView) -> Promise<YLBannerView> {
        let bannerView = ylBannerView.getBannerView()
        guard let ylAdDelegate = bannerView.delegate as? AdDelegate else {
            return Promise(error: YLGamAdLoaderError.cannotCastToYLAdDelegate)
        }
        ylAdDelegate.replacePromise()
        bannerView.load(gamRequestData.gamRequest)
        return ylAdDelegate.promise
    }

    func loadInterstitial(gamRequestData: GamInstlRequestData, timeEventRecorder: TimeEventRecorder) -> Promise<GAMInterstitialAd> {
        let (promise, resolver) = Promise<GAMInterstitialAd>.pending()
        recordGamRequest(timeEventRecorder: timeEventRecorder)
        let completionHandler = getInstlCompletion(requestData: gamRequestData,
                                                      recorder: timeEventRecorder,
                                                      resolver: resolver)
        gamInterstitialProvider.load(withAdManagerAdUnitID: gamRequestData.adUnitData.adUnit,
                                     request: gamRequestData.gamRequest,
                                     completionHandler: completionHandler)
        return promise
    }
    
    func loadRewardedAd(gamRequestData: RewardedRequestData, timeEventRecorder: TimeEventRecorder) -> Promise<GADRewardedAd> {
        let (promise, resolver) = Promise<GADRewardedAd>.pending()
        recordGamRequest(timeEventRecorder: timeEventRecorder)
        let completionHandler = getRewardedCompletion(requestData: gamRequestData,
                                                                recorder: timeEventRecorder,
                                                                resolver: resolver)
        
        gamRewardedAdProvider.load(withAdUnitID: gamRequestData.adUnitData.adUnit,
                                   request: gamRequestData.gamRequest,
                                   completionHandler: completionHandler)
        
        return promise
    }

    private func startRefreshTimer(gamRequestData: GamRequestData, ylBanner: YLRefreshableBanner, referenceHolder: YLReferenceHolder) {
        let config = ylBanner.config
        let adUnitData = gamRequestData.adUnitData
        let timerFactory = config.refreshTimerFactory
        if let autoRefreshTimeMs = adUnitData.autoRefreshTimeMs {
            let refreshTimer = timerFactory.makeTimer(autoRefreshTimeMs: autoRefreshTimeMs,
                                                      delegate: ylBanner,
                                                      referenceHolder: referenceHolder)
            YLRefreshTimerCollection.instance.setTimer(adUnit: adUnitData.adUnit, refreshTimer)
            refreshTimer.start()
        }
    }

    /*
     * Why keep a reference to GAMBannerView and YieldloveAdDelegate?
     * If YieldloveAdDelegate is released from memory during ad request,
     * there will be no object on which to call bannerViewDidReceiveAd()
     * or bannerViewDidFailToReceiveAdWithError()
     * If GAMBannerView is released from memory during ad request,
     * none of the delegate methods will be called. Releasing this object
     * signals to the GAM that app has moved on and is not waiting for ad.
     */
    private func keepReference(_ referenceHolder: YLReferenceHolder, ylAd: YLAd) {
        let referenceManager = ylAd.config.referenceManager
        referenceManager.add(referenceHolder: referenceHolder)
    }

    private func getInstlCompletion(requestData: GamInstlRequestData, recorder: TimeEventRecorder, resolver: Resolver<GAMInterstitialAd>)
            -> InstlCompletion {
        return { ad, error in
            self.recordGamResponse(timeEventRecorder: recorder, error: error)
            resolver.resolve(ad, error)
        }
    }
    
    private func getRewardedCompletion(requestData: RewardedRequestData, recorder: TimeEventRecorder, resolver: Resolver<GADRewardedAd>)
            -> RewardedCompletion {
        return { ad, error in
            self.recordGamResponse(timeEventRecorder: recorder, error: error)
            resolver.resolve(ad, error)
        }
    }

    private func recordGamRequest(timeEventRecorder: TimeEventRecorder?) {
        timeEventRecorder?.recordGamRequested()
    }

    private func recordGamResponse(timeEventRecorder: TimeEventRecorder, error: Error?) {
        if let err = error {
            timeEventRecorder.recordGamRespondedWithError(error: err)
        } else {
            timeEventRecorder.recordGamRespondedSuccessfully()
        }
    }
}
