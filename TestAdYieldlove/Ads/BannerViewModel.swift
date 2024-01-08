//
//  BannerViewModel.swift
//  Herzrasen-Swift
//
//  Created by Josip Bernat on 14.11.2022..
//

import Foundation
import UIKit

enum BannerIdentifier: String {
    case interstitial  = "startseite_rubrik_int"
}


protocol TimerViewModel: AnyObject {
 
    var isTabVisible: Bool { get set }
    var delayTimer: Timer? { get set }
    var isActive: Bool { get } // This property is here only for easier debugging because on iPad we have logs that are unneded.
}

extension TimerViewModel {
    
    func loadDelayTimer(callback: (() -> Void)?) {
        
//        print("**** scheduling delay timer")
        
        delayTimer?.invalidate()
        delayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { [weak self] _ in
            
            self?.delayTimer = nil
            guard let uSelf = self, uSelf.isTabVisible else { return }
            
//            print("**** delay timer fired!")
            callback?()
        })
    }
    
    func tabOpened() {
        guard isTabVisible == false, isActive else {
            return
        }
//        print("*** tabOpened")
        isTabVisible = true
    }

    func tabClosed() {
        guard isTabVisible, isActive else {
            return
        }
//        print("*** tabClosed")
        isTabVisible = false
    }
}

protocol BannerViewModel: TimerViewModel {
    
    var isLoadingBannerView: Bool { get set }
    typealias Banner = (view: UIView, size: CGSize, timestamp: Date)
    
    var cachedBanner: Banner? { get set }
    var activeBanner: Banner? { get set }
    var canLoadAds: Bool { get }
    var bannerViewController: UIViewController? { get }
    var bannerId: BannerIdentifier? { get }
    
    func invalidateAdBanner(reloadList: Bool)
    func onAdLoaded()
}

extension BannerViewModel {
    
    var banner: Banner? {
        if let activeBanner = activeBanner {
            return activeBanner
        } else {
            return cachedBanner
        }
    }
    
    var canLoadAds: Bool {
#if !TEST
        YieldloveAdIntegrationBridge.shared.isConsentReady
#else
        return false
#endif
    }

    func tabOpened(loadAds: Bool, automaticallyInvalidateBanner: Bool = true) {
        
        guard isTabVisible == false, isActive else {
            return
        }
//        print("*** tabOpened")
        isTabVisible = true
        
        if automaticallyInvalidateBanner {
            invalidateAdBannerIfNeeded()
        }
        
        if loadAds {
            self.loadAds()
        }
    }
    
    func loadAdWithDelayTimer(callback: (() -> Void)?) {
        
        loadDelayTimer { [weak self] in
            self?.loadAds()
            callback?()
        }
    }
    
    func loadAds() {
                
        guard let viewController = bannerViewController else { return }
        
        guard canLoadAds,
                isLoadingBannerView == false,
                activeBanner == nil,
                isTabVisible else { return }
        
        guard let bannerId = bannerId else { return }
        
        isLoadingBannerView = true
        
//        print("**** loading banner: \(bannerId)")
                
        YieldloveAdIntegrationBridge
            .shared
            .requestAdWithoutAddingToView(adSlotId: bannerId.rawValue, inViewController: viewController) { [weak self] size, newBanner, _ in
                
                guard let banner = newBanner else {
                    self?.isLoadingBannerView = false
                    return
                }
                
                let view = banner.getBannerView()
                
                self?.activeBanner = (view, size, Date())
                self?.cachedBanner = self?.activeBanner
                self?.onAdLoaded()
                self?.isLoadingBannerView = false
        }
    }
    
    static var timeIntervalAfterAdShouldBeInvalidated: TimeInterval {
        15.0
    }
    
    func invalidateAdBannerIfNeeded() {
        
        if let activeBanner = activeBanner, fabs(activeBanner.timestamp.timeIntervalSinceNow) > Self.timeIntervalAfterAdShouldBeInvalidated {
            invalidateAdBanner(reloadList: false)
        }
    }
    
    func invalidateAdBanner(reloadList: Bool) {
        
        if activeBanner != nil {
            print("**** invalidating ad for id: \(bannerId!)")
        }
        
        activeBanner = nil
        
        if reloadList {
            cachedBanner = nil
        }
    }
}
