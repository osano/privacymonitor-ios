//
//  AppDelegate.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import CleanroomLogger
import UIKit

protocol WelcomeFlowHandler {
    func handleWelcome(withWindow window: UIWindow?)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WelcomeFlowHandler {

    var window: UIWindow?

    override init() {
        super.init()
        Log.enable()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        window = UIWindow(frame: UIScreen.main.bounds)
        handleWelcome(withWindow: window)

        UserSettingsHelper.registerDefaults()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension WelcomeFlowHandler {

    func handleWelcome(withWindow window: UIWindow?) {

        if UserSettingsHelper.hasSeenWelcomeScreen() {
            // User has seen the welcome screen before, let's continue
            showMainApp(withWindow: window)
        }
        else {
            // Show welcome screen
            showWelcome(withWindow: window)
        }
    }

    func showWelcome(withWindow window: UIWindow?) {
        guard let viewController = UIStoryboard(name: Constants.StoryboardID.welcome, bundle: nil).instantiateInitialViewController() as? WelcomeViewController else {
            Log.error?.message("\(Constants.StoryboardID.welcome) Storyboard can't be loaded.")
            return
        }

        window?.subviews.forEach { $0.removeFromSuperview() }
        window?.rootViewController = nil
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }

    func showMainApp(withWindow window: UIWindow?) {
        guard let viewController = UIStoryboard(name: Constants.StoryboardID.webView, bundle: nil).instantiateInitialViewController() as? UINavigationController else {
            Log.error?.message("\(Constants.StoryboardID.webView) Storyboard can't be loaded.")
            return
        }

        window?.subviews.forEach { $0.removeFromSuperview() }
        window?.rootViewController = nil
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}
