//
//  AppDelegate.swift
//  enHueco
//
//  Created by Diego Gómez on 1/24/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity
import FBSDKCoreKit
import Fabric
import Crashlytics
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    static var sharedDelegate: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    /// The navigation to which the login controller belongs
    var mainNavigationController: UINavigationController!

    var window: UIWindow?

    /// If we are currently logging out
    var loggingOut = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {

        // Start Firebase
        FIRApp.configure()

        // Start Crashlitics
        Fabric.with([Crashlytics.self])

        // Start FBSDK
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        if #available(iOS 9.0, *) {
            if WCSession.isSupported() {
                let session = WCSession.defaultSession()
                session.delegate = self
                session.activateSession()
            }
        }

        if NSUserDefaults.standardUserDefaults().boolForKey("notFirstLaunch") {
            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
            
        } else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "notFirstLaunch")
        }

        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))

        return true
    }

    func applicationWillResignActive(application: UIApplication) {

        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {

        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        ProximityUpdatesManager.sharedManager.updateBackgroundFetchInterval()
    }

    func applicationWillEnterForeground(application: UIApplication) {

        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {

        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {

        return UI_USER_INTERFACE_IDIOM() == .Phone ? .Portrait : .All
    }

    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveMessage message: [String:AnyObject], replyHandler: ([String:AnyObject]) -> Void) {

        /*
        if message["request"] as! String == "friendsCurrentlyInGap"
        {
            var responseDictionary = [String : AnyObject]()
            let friendsCurrentlyFreeAndFreeTimePeriods = CurrentStateManager.sharedManager.currentlyAvailableFriends()
            
            var friendsArray = [[String : AnyObject]]()
            
            for (friend, freeTimePeriod) in friendsCurrentlyFreeAndFreeTimePeriods
            {
                var friendDictionary = [String : AnyObject]()
                
                friendDictionary["name"] = friend.name
                friendDictionary["imageURL"] = friend.imageURL?.absoluteString
                friendDictionary["gapEndDate"] = freeTimePeriod.endHourInNearestPossibleWeekToDate(NSDate())
                
                friendsArray.append(friendDictionary)
            }
            
            responseDictionary["friends"] = friendsArray
            
            replyHandler(responseDictionary)
        }
        */
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {

        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    // TODO: Update when the time comes
    /*
    func proximityManagerDidReceiveProximityUpdates(notification: NSNotification)
    {
        let minTimeIntervalToNotify = /*2.0*/ 60*80 as NSTimeInterval
        
        let friendsToNotifyToUser = CurrentStateManager.sharedManager.friendsCurrentlyNearby().filter { $0.lastNotifiedNearbyStatusDate == nil || $0.lastNotifiedNearbyStatusDate?.timeIntervalSinceNow > minTimeIntervalToNotify }
        
        let currentDate = NSDate()
        
        for friendToNotify in friendsToNotifyToUser
        {
            friendToNotify.lastNotifiedNearbyStatusDate = currentDate
        }
     
        if !friendsToNotifyToUser.isEmpty
        {
            var notificationText = ""
            
            for (i, friend) in friendsToNotifyToUser.enumerate()
            {
                if i <= 3
                {
                    notificationText += friend.firstNames
                    
                    if i == friendsToNotifyToUser.count-1 && friendsToNotifyToUser.count > 1
                    {
                        notificationText += " y "
                    }
                    else
                    {
                        notificationText += (i != 0 ? ", ":"")
                    }
                }
                else { break }
            }
            
            if friendsToNotifyToUser.count > 3
            {
                notificationText += " y otros amigos"
            }
            
            if friendsToNotifyToUser.count > 1
            {
                notificationText += " parecen estar cerca y en hueco, ¿por qué no les escribes?"
            }
            else
            {
                notificationText += " parece estar cerca y en hueco, ¿por qué no le escribes?"
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                //TODO: FIX
                //TSMessage.showNotificationWithTitle(notificationText, type: .Message)
            }
        }
    }*/
}

