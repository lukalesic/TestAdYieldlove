//
//  ViewController.swift
//  TestAdYieldlove
//
//  Created by Luka Lešić on 08.01.2024..
//

import UIKit
import YieldloveAdIntegration
import PureLayout

class ViewController: UIViewController {
    
    let adLoader = YieldloveAdIntegrationBridge.shared
    var containerView = UIView()

    func setupAdContainer() {
        containerView.frame = CGRect(origin: .zero, size: CGSize(width: 320, height: 50))
        view.addSubview(containerView)
        containerView.autoCenterInSuperview()
    }
    
    func requestAd() {
        //NOTE: to make sure the ad request is sent, I have removed consent check in "requestAd" function and set isConsentReady var to true in IntegrationBridge on initialization
        DispatchQueue.main.async {
            self.adLoader.requestAd(with: "main_screens_b1",
                                    inViewController: self,
                                    addedTo: self.containerView) { (adSize, bannerView, error) in
                print("***ad requested")
                
                if let error = error {
                    print("***ad error: \(error.localizedDescription)")
                } else {
                    print("***Ad loaded successfully!")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        setupAdContainer()
        requestAd()
    }
}

