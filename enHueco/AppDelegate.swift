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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate
{
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Override point for customization after application launch.
                
        if #available(iOS 9.0, *)
        {
            if WCSession.isSupported()
            {
                let session = WCSession.defaultSession()
                session.delegate = self
                session.activateSession()
            }
        }
        
        let notFirstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("notFirstLaunch")
        
        if notFirstLaunch
        {
            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
        }
        else
        {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "notFirstLaunch")
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication)
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        try? system.persistData()
    }

    func applicationDidEnterBackground(application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication)
    {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if let appUser = system.appUser
        {
            appUser.fetchUpdatesForAppUserAndSchedule()
            appUser.fetchUpdatesForFriendsAndFriendSchedules()
            SynchronizationManager.sharedManager().retryPendingRequests()
        }
    }

    func applicationWillTerminate(application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void)
    {
        let (currentGap, nextGap) = system.appUser.currentAndNextGap()
        
        if currentGap != nil
        {
            //Ask iOS to kindly try to wake up the app frequently during gaps.
            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(ProximityManager.backgroundFetchIntervalDuringGaps)
            
            ProximityManager.sharedManager().reportCurrentBSSIDAndFetchUpdatesForFriendsLocationsWithSuccessHandler({ () -> () in
                
                completionHandler(.NewData)
                
            }, networkFailureHandler: { () -> () in
                    
                completionHandler(.Failed)
                    
            }, notConnectedToWifiHandler: { () -> () in
                    
                completionHandler(.NoData)
            })
        }
        else if let nextGap = nextGap
        {
            //If the user is not in gap ask iOS to try to wake up app as soon as user becomes free.
            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval( nextGap.endHourInDate(NSDate()).timeIntervalSinceNow )
            
            completionHandler(.NoData)
        }
        else
        {
            //The day is over, user doesn't have more gaps ahead, we're going to preserve their battery life by asking iOS to try to wake app less frequently
            //TODO : Set fetch interval to wait for next gap (for this we must look for the next gap in future days)
            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(ProximityManager.backgroundFetchIntervalAfterDayOver)
            
            completionHandler(.NoData)
        }
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return UI_USER_INTERFACE_IDIOM() == .Phone ? .Portrait : .All
    }
    
    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void)
    {
        if message["request"] as! String == "friendsCurrentlyInGap"
        {
            var responseDictionary = [String : AnyObject]()
            let friendsInGapAndGaps = system.appUser.friendsCurrentlyInGap()
            
            var friendsArray = [[String : AnyObject]]()
            
            for (friend, gap) in friendsInGapAndGaps
            {
                var friendDictionary = [String : AnyObject]()
                
                friendDictionary["name"] = friend.name
                friendDictionary["imageURL"] = friend.imageURL?.absoluteString
                friendDictionary["gapEndDate"] = gap.endHourInDate(NSDate())
                
                friendsArray.append(friendDictionary)
            }
            
            responseDictionary["friends"] = friendsArray
            
            replyHandler(responseDictionary)
        }
    }
}

