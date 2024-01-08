//
//  YieldloveAdIntegrationBridge.swift
//  Herzrasen-Swift
//
//  Created by Josip Bernat on 15.06.2022..
//

import Foundation
import YieldloveAdIntegration;
import YieldloveConsent;
import GoogleMobileAds
import ConsentViewController;
import PrebidMobile

//MARK: - YieldAdLoader

fileprivate class YieldAdLoader: YLBannerViewDelegate {

    typealias AdLoaderCompletion = ((CGSize, YLBannerView?, Error?, UUID) -> Void)
    var completion: AdLoaderCompletion?
    var uuid = UUID()
    var viewToAdd: UIView?
    var inViewController: UIViewController?

    //MARK: - Initialization

    init(adSlotId: String, inViewController: UIViewController, viewToAdd: UIView?, completion: @escaping AdLoaderCompletion) {
        self.completion = completion
        self.viewToAdd = viewToAdd
        self.inViewController = inViewController

        Yieldlove.instance.bannerAd(adSlotId: adSlotId, viewController: inViewController, delegate: self)
    }

    //MARK: - YLBannerViewDelegate

    func bannerViewDidReceiveAd(_ bannerView: YLBannerView) {

        DispatchQueue.main.async { [unowned self] in
                                  
            let banner = bannerView.getBannerView()
            let fakeView = UIView()
            fakeView.addSubview(banner)

            Yieldlove.instance.resizeBanner(banner: bannerView) { [unowned self] in
                
                let size = bannerView.getBannerView().adSize.size
                banner.removeFromSuperview()

                if let uView = self.viewToAdd {

                    var adView:UIView? = nil
                    for view in uView.subviews {
                        if (view.isKind(of: GADBannerView.self)) {
                            adView = view
                            break
                        }
                    }
                    adView?.removeFromSuperview()

                    let actualBannerView = bannerView.getBannerView()
                    uView.addSubview(actualBannerView)
                    actualBannerView.autoCenterInSuperview()
                }
                
                self.completion?(size, bannerView, nil, self.uuid)
            }
        }
    }
    
    func bannerView(_ bannerView: YLBannerView, didFailToReceiveAdWithError error: Error) {
        DispatchQueue.main.async { [unowned self] in
            self.completion?(.zero, nil, error, self.uuid)
        }
    }
}
 
//MARK: - YieldloveAdIntegrationBridge

@objc class YieldloveAdIntegrationBridge: NSObject {

    @objc static let shared = YieldloveAdIntegrationBridge()
    @objc static let onConsentReadyDidUpdateNotification = "onConsentReadyDidUpdateNotification"
    @objc private(set) var isConsentReady: Bool = true

    private var isConsentNotificationPosted = false
    private var adLoaders = [UUID: YieldAdLoader]()

    //MARK: - Initializaiton
    override init() {
        super.init()

        Yieldlove.setup(appName: "smb_quizquest")
        YLConsent.instance.setAppName(appName: "smb_quizquest")
//        
        #if DEBUG
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "871aa86b01c20772d6aa83d4ab6fbf26" ]
        #endif
    }

    typealias AdCompletion = ((CGSize, YLBannerView?, Error?) -> Void)

    //MARK: - Requesting Ads
    
    @objc func requestAdWithoutAddingToView(adSlotId: String, inViewController: UIViewController, completion: AdCompletion?) {

        guard isConsentReady else { return }
        
//        print("*** requestAdWithoutAddingToView: \(adSlotId)")

        let loader = YieldAdLoader(adSlotId: adSlotId, inViewController: inViewController, viewToAdd: nil) { (adSize, bannerView, error, uuid) in
            self.adLoaders.removeValue(forKey: uuid)
            completion?(adSize, bannerView, error)
            if let error = error {
                print("Error when loading ad: \(adSlotId), error: \(error)")
            }
        }
        adLoaders[loader.uuid] = loader
    }

    @objc func requestAd(with adSlotId: String, inViewController: UIViewController, addedTo view: UIView, completion:AdCompletion?) {

//        guard isConsentReady else { return }

        let loader = YieldAdLoader(adSlotId: adSlotId, inViewController: inViewController, viewToAdd: view) { (adSize, bannerView, error, uuid) in
            self.adLoaders.removeValue(forKey: uuid)
            completion?(adSize, bannerView, error)
        }
        adLoaders[loader.uuid] = loader
    }

    //MARK: - Interstitial
    
    @objc func requestInterstitial(adSlotId: String, viewController: UIViewController, completion: ((Error?) -> Void)? = nil) {
        guard isConsentReady else { return }

        Yieldlove.instance.interstitialAd(adSlotId: adSlotId) { interstitial, error in
            
            if let uError = error {
                completion?(uError)
            }
            else {
                if let navController = viewController.navigationController {
                    interstitial?.present(fromRootViewController: navController)
                } else {
                    interstitial?.present(fromRootViewController: viewController)
                }
                completion?(nil)
            }
        }
    }
    
    //MARK: - Consent

    private var consentCompletion: (() -> Void)?
    @objc public func presentConsent(in viewController: UIViewController, completion: (() -> Void)?) {
        self.consentCompletion = completion
        
        let options = ConsentOptions()
        options.language = .German
        YLConsent.instance.collect(viewController: viewController, delegate: self, options: options)
    }

    private var onReadyOrErrorCallback: (() -> Void)?
    @objc public func presentPrivacyManager(in viewController: UIViewController, onReadyOrError:(() -> Void)?) {
        onReadyOrErrorCallback = onReadyOrError
        
        let options = ConsentOptions()
        options.language = .German
        YLConsent.instance.showPrivacyManager(viewController: viewController,
                                              delegate: self,
                                              options: options)
    }
}

extension YieldloveAdIntegrationBridge: ConsentDelegate {

    //MARK: - ConsentDelegate

    func onError(error: YieldloveConsentError) {
        onReadyOrErrorCallback?()
        onReadyOrErrorCallback = nil
    }
    
    func onSPUIReady() {
        onReadyOrErrorCallback?()
        onReadyOrErrorCallback = nil
    }
  
    func onConsentReady(consents: SPUserData) {
        self.isConsentReady = true
        guard isConsentNotificationPosted == false else { return }
        isConsentNotificationPosted = true
        
        if let uCompletion = consentCompletion {
            uCompletion()
            consentCompletion = nil
        }
                   
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YieldloveAdIntegrationBridge.onConsentReadyDidUpdateNotification), object: nil)
    }
}
