//
//  SceneDelegate.swift
//  TestAdYieldlove
//
//  Created by Luka Lešić on 08.01.2024..
//

import UIKit
import AppTrackingTransparency

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        let navController = UINavigationController(rootViewController: ViewController())
        navController.navigationBar.prefersLargeTitles = true

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
         //   guard let root = UIApplication.shared.rootViewController else { return }
            guard let root = self.window?.rootViewController else { return }

            self.requestConsent(rootViewController: root) {
                print("***consent requested in SceneDelegate")
            }
        }
    }

    private func requestConsent(rootViewController: UIViewController, completion: @escaping (() -> Void)) {
                    
            YieldloveAdIntegrationBridge.shared.presentConsent(in: rootViewController) {
                //I have set minimum app target as iOS 13
                if #available(iOS 14, *) {
                    ATTrackingManager.requestTrackingAuthorization { (status) in
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

