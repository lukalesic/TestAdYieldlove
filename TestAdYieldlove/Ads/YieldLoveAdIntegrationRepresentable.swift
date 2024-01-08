//
//  YieldLoveAdIntegrationRepresentable.swift
//  QuizQuest
//
//  Created by Luka Lešić on 28.04.2023..
//

import Foundation
import UIKit
import SwiftUI
import PureLayout
import YieldloveAdIntegration

struct YieldLoveAdIntegrationBridgeRepresentable: UIViewRepresentable {
    let adLoader = YieldloveAdIntegrationBridge.shared
    let adSlotId: String
    var containerView = UIView()
    @State var placeholderSize: CGSize
    
    func makeUIView(context: Context) -> UIView {
        containerView.frame = CGRect(origin: .zero, size: CGSize(width: 320, height: 50))
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
        DispatchQueue.main.async {
            adLoader.requestAd(with: adSlotId,
                               inViewController: UIApplication.shared.visibleViewController!,
                               addedTo: containerView) { (adSize, bannerView, error) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    if let error = error {
                        print("***ad error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}


