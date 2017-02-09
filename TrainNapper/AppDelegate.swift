//
//  AppDelegate.swift
//  TrainNapper
//
//  Created by Robert Deans on 12/24/16.
//  Copyright © 2016 Robert Deans. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Firebase
import GoogleMobileAds
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let googleAPI = "AIzaSyDLkK5fHf0Q6p0l1g521hqlg1UWAVZ7kgo"
    let appID = "ca-app-pub-2779558823377577~4750570444"
    
    var window: UIWindow?
    var homeViewController: UIViewController!
    var navigationController: UINavigationController!
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FIRApp.configure()
        GADMobileAds.configure(withApplicationID: appID)
        
        GMSServices.provideAPIKey(googleAPI)
        GMSPlacesClient.provideAPIKey(googleAPI)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        homeViewController = HomeViewController()

        navigationController = UINavigationController()
//        navigationController.navigationBar.barTintColor = UIColor.mainColor
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController.viewControllers = [homeViewController]
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
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

