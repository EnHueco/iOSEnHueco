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
import APAddressBook

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    /// The navigation to which the login controller belongs
    var mainNavigationController: UINavigationController!

    var window: UIWindow?

    /// If we are currently logging out
    var loggingOut = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Start Firebase
        FIRApp.configure()

        // Start Crashlitics
        Fabric.with([Crashlytics.self])

        // Start FBSDK
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if AccountManager.shared.userID != nil {
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "MainTabBarViewController") as! MainTabBarViewController
        } else {
            window?.rootViewController = storyboard.instantiateInitialViewController()
        }
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        
        // FIXME: Implement correctly or remove
        
        //        if #available(iOS 9.0, *) {
        //            if WCSession.isSupported() {
        //                let session = WCSession.default()
        //                session.delegate = self
        //                session.activate()
        //            }
        //        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        ProximityUpdatesManager.shared.updateBackgroundFetchInterval()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {

        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {

        return UI_USER_INTERFACE_IDIOM() == .phone ? .portrait : .all
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    // TODO: Update when the time comes
    /*
    func proximityManagerDidReceiveProximityUpdates(notification: NSNotification)
    {
        let minTimeIntervalToNotify = /*2.0*/ 60*80 as NSTimeInterval
        
        let friendsToNotifyToUser = CurrentStateManager.shared.friendsCurrentlyNearby().filter { $0.lastNotifiedNearbyStatusDate == nil || $0.lastNotifiedNearbyStatusDate?.timeIntervalSinceNow > minTimeIntervalToNotify }
        
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

// TODO: Implement correctly or remove

//@available(iOS 9.0, *)
//extension AppDelegate: WCSessionDelegate {
//    
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
//        
//        /*
//         if message["request"] as! String == "friendsCurrentlyInGap"
//         {
//         var responseDictionary = [String : Any]()
//         let friendsCurrentlyFreeAndFreeTimePeriods = CurrentStateManager.shared.currentlyAvailableFriends()
//         
//         var friendsArray = [[String : Any]]()
//         
//         for (friend, freeTimePeriod) in friendsCurrentlyFreeAndFreeTimePeriods
//         {
//         var friendDictionary = [String : Any]()
//         
//         friendDictionary["name"] = friend.name
//         friendDictionary["imageURL"] = friend.imageURL?.absoluteString
//         friendDictionary["gapEndDate"] = freeTimePeriod.endHourInNearestPossibleWeekToDate(NSDate())
//         
//         friendsArray.append(friendDictionary)
//         }
//         
//         responseDictionary["friends"] = friendsArray
//         
//         replyHandler(responseDictionary)
//         }
//         */
//    }
//    
//    func sessionDidBecomeInactive(_ session: WCSession) {}
//    
//    func sessionDidDeactivate(_ session: WCSession) {}
//}

extension AppDelegate {
    
    // TODO: Move later to a dedicated manager
    func callFriend(_ phoneNumber : String) {
        guard let url = URL(string: "tel://\(phoneNumber)") else { return }
        UIApplication.shared.openURL(url)
    }
    
    // TODO: Move later to a dedicated manager
    func whatsappMessageTo(_ friendABID : NSNumber?) {
        guard let url = URL(string: "whatsapp://send?" + ((friendABID == nil) ? "": "abid=\(friendABID!)")) else { return }
        UIApplication.shared.openURL(url)
    }
    
    // TODO: Move later to a dedicated manager
    func getFriendABID(_ phoneNumber : String, completionHandler : @escaping (_ abid: NSNumber?) -> ()) {
        
        // FIXME
//        let addressBook = APAddressBook()
//        addressBook.fieldsMask =  APContactField.Phones.union(APContactField.RecordID)
//        
//        addressBook.loadContacts({ (contacts: [Any]!, error: NSError!) in
//            
//            guard let contacts = contacts else {
//                completionHandler(abid: nil)
//                return
//            }
//            
//            for contact in contacts {
//                guard let contactAP = contact as? APContact else { continue }
//                
//                for phone in contactAP.phones ?? [] {
//                    guard var phoneString = phone as? String else { continue }
//                    
//                    phoneString = phoneString.stringByReplacingOccurrencesOfString("(", withString: "")
//                    phoneString = phoneString.stringByReplacingOccurrencesOfString(")", withString: "")
//                    phoneString = phoneString.stringByReplacingOccurrencesOfString("-", withString: "")
//                    phoneString = phoneString.stringByReplacingOccurrencesOfString(" ", withString: "")
//                    phoneString = phoneString.stringByReplacingOccurrencesOfString("+", withString: "")
//                    phoneString = phoneString.stringByReplacingOccurrencesOfString(" ", withString: "")
//                    
//                    if phoneString.rangeOfString(phoneNumber) != nil {
//                        completionHandler(abid: contactAP.recordID)
//                        return
//                    }
//                }
//            }
//        })
//        return
    }
}
