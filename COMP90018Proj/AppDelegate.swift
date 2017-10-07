//
//  AppDelegate.swift
//  COMP90018Proj
//
//  Created by Kai Zhang on 28/9/17.
//  Copyright © 2017 Unimelb. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import ImagePicker
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UITabBarControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let tabBarController = ESTabBarController()
        tabBarController.delegate = self
        tabBarController.tabBar.backgroundImage = UIImage(named: "background_dark")

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let v3 = storyBoard.instantiateViewController(withIdentifier: "crimeInfo")
        let v2 = storyBoard.instantiateViewController(withIdentifier: "faceIdent")
        let v1 = storyBoard.instantiateViewController(withIdentifier: "howToUse")

        v1.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "How to Use",image: UIImage(named: "find"), selectedImage: UIImage(named: "find_1"))
        v2.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "Face Identify",image: UIImage(named: "photo_verybig"), selectedImage: UIImage(named: "photo_verybig-1"))
        v3.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "Crime Info",image: UIImage(named: "cardboard"), selectedImage: UIImage(named: "cardboard_1"))

        tabBarController.viewControllers = [v1, v2, v3]
       
        self.window?.rootViewController = tabBarController
        tabBarController.title = "Identify Crime Nearby"
        
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

