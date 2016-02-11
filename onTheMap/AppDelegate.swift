//
//  AppDelegate.swift
//  onTheMap
//
//  Created by Sebas on 1/10/16.
//  Copyright © 2016 Sebas. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var studentKey = ""
    
    //facebook
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Override point for customization after application launch.
        let result = FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // Clear any lingering Facebook sessions which may be active
        // out of sync with the application
        FBSDKLoginManager().logOut()
        return result
    }
      //facebook
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    //problems with back to app button after pressing sign up
    func applicationDidEnterBackground(application: UIApplication) {
        // Then push that view controller onto the navigation stack
       if (FBSDKAccessToken.currentAccessToken() == nil && studentKey == "") {
            let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let homeViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginView") as! LoginViewController
            let nav = UINavigationController(rootViewController: homeViewController)
            appdelegate.window!.rootViewController = nav
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Removes any login sessions when the app closes
        
          UdacityClient.sharedInstance().logout(self)
    }
}