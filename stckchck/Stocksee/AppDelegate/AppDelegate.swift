//
//  AppDelegate.swift
//  stckchck
//
//  Created by Pho on 21/08/2018.
//  Copyright © 2018 stckchck. All rights reserved.
//

import UIKit
import Firebase
import Fabric
import Crashlytics
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ app: UIApplication, open url: URL, options:[UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation]) {
            return handled
        } else {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Setup Firebase/Firestore/Facebook Login
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        let _ = RemoteConfigManager.sharedInstance
        
        settings.areTimestampsInSnapshotsEnabled = true
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        databaseRef.settings = settings
        
        //Setup Crashlytics/Fabric
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
        
        let walkthroughLaunchService = WalkthroughLaunchService(userDefaults: .standard, key: "com.stckchckMVP.FirstLaunch.WasLaunchedBefore")
        if walkthroughLaunchService.isFirstLaunch {

            print("deadBeef appDel_dFLWO isFirstLaunch = true")

            self.window? = UIWindow(frame: UIScreen.main.bounds)
            let walkThroughStoryboard = UIStoryboard(name: "WalkThrough", bundle: nil)

            let pageControl = walkThroughStoryboard.instantiateViewController(withIdentifier: "PageControl") as UIViewController

            self.window?.rootViewController = pageControl
            self.window?.makeKeyAndVisible()

        } else {
            print("deadBeef appDel_dFLWO isFirstLaunch = false")
            //only start observing if it isnt the first launch, otherwise we wont be able to load the products in the mfTVC
            DispatchQueue.main.async {
                ReachabilityManager.sharedInstance.startMonitoringNetworkReachability()
            }
        }
        
//        For testing (always first launch) use:
//        let alwaysFirstLaunch = WalkthroughLaunchService.alwaysFirstLaunch()
//        if alwaysFirstLaunch.isFirstLaunch {
//            print("deadBeef appDel_dFLWO")
//            self.window? = UIWindow(frame: UIScreen.main.bounds)
//            let walkThroughStoryboard = UIStoryboard(name: "WalkThrough", bundle: nil)
//
//            let pageControl = walkThroughStoryboard.instantiateViewController(withIdentifier: "PageControl") as UIViewController
//
//            self.window?.rootViewController = pageControl
//            self.window?.makeKeyAndVisible()
//        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        ReachabilityManager.sharedInstance.stopMonitoringNetworkReachability()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        ReachabilityManager.sharedInstance.startMonitoringNetworkReachability()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
//        print("deadBeef appDel_aDBA wLS.isFirstLaunch: \(walkthroughLaunchService.isFirstLaunch)")
            //This check always returns false for some reason
//        if walkthroughLaunchService.isFirstLaunch == false {
//            ReachabilityManager.sharedInstance.startMonitoringNetworkReachability()
//        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


