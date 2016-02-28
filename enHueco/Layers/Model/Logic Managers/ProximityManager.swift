//
//  ProximityManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 11/3/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork
import ReachabilitySwift

class EHProximityManagerNotification
{
    static let ProximityManagerDidReceiveProximityUpdates = "ProximityManagerDidReceiveProximityUpdates"
}

enum ProximityManagerReportingCompletionStatus
{
    case NotConnectedToWifi
    case NetworkFailure
    case Success
}

class ProximityManager: NSObject
{
    static private var instance = ProximityManager()
    
    static let backgroundFetchIntervalDuringFreeTimePeriods = 5 * 60.0
    static let backgroundFetchIntervalAfterDayOver = 7*3600.0
    
    ///Graph with BSSIDs of the access points
    private let wifiAccessPointsGraph = UnweightedGraph<String>()
    
    /// Temporary solution: Timer to trigger location updates with the server while app open
    private var proximityInformationRefreshTimer: NSTimer!
    
    private override init()
    {
        super.init()
    }
    
    static func sharedManager() -> ProximityManager
    {
        return instance
    }
    
    ///Temporary
    private func scheduleProximityInformationRefreshTimer()
    {
        proximityInformationRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("proximityInformationRefreshTimerTicked:"), userInfo: nil, repeats: true)
    }
    
    func proximityInformationRefreshTimerTicked(timer:NSTimer)
    {
        reportCurrentBSSIDAndFetchUpdatesForFriendsLocationsWithSuccessHandler { _ -> () in }
    }
    
    ///Temporary
    func beginProximityUpdates()
    {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        {
            //self.generateGraphFromFile()
            
            dispatch_async(dispatch_get_main_queue())
            {
                self.scheduleProximityInformationRefreshTimer()
            }
        }
    }
    
    //Temporary
    func generateGraphFromFile()
    {
        let fileLocation = NSBundle.mainBundle().pathForResource("accessPoints", ofType: "csv")!
        
        var csvString = try! String(contentsOfFile: fileLocation, encoding: NSUTF8StringEncoding)
        csvString = csvString.stringByReplacingOccurrencesOfString("\"", withString: "")
        csvString = csvString.stringByReplacingOccurrencesOfString(", ", withString: ",")
        
        let csv = CSwiftV(String: csvString)
        
        var rows = csv.keyedRows!
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm:ss a"
        
        rows = rows.sort
        {
            let dateComparison = formatter.dateFromString($0["Time"]!.substringFromIndex($0["Time"]!.startIndex))!.compare(formatter.dateFromString($1["Time"]!.substringFromIndex($1["Time"]!.startIndex))!)
            
            if dateComparison != .OrderedSame
            {
                return dateComparison == .OrderedAscending
            }
            else
            {
                return Int($0["RSSI"]!.stringByReplacingOccurrencesOfString(" ", withString: "")) > Int($1["RSSI"]!.stringByReplacingOccurrencesOfString(" ", withString: ""))
            }
        }
        
        var currentDate = ""
        var referenceAccessPointIndex: Int!
        
        for row in rows
        {
            if row["Time"] != currentDate
            {
                //We are in the AP with the best signal
                currentDate = row["Time"]!
                referenceAccessPointIndex = wifiAccessPointsGraph.indexOf(row["BSS"]!) ?? wifiAccessPointsGraph.addVertex(row["BSS"]!)
            }
            else
            {
                let visibleAccessPointFromReferenceIndex = wifiAccessPointsGraph.indexOf(row["BSS"]!) ?? wifiAccessPointsGraph.addVertex(row["BSS"]!)
                
                if !wifiAccessPointsGraph.edgeExists(referenceAccessPointIndex, to: visibleAccessPointFromReferenceIndex)
                {
                    wifiAccessPointsGraph.addEdge(referenceAccessPointIndex, to: visibleAccessPointFromReferenceIndex)
                }
            }
        }
    }
    
    func wifiAccessPointWithBSSID(bssidA: String, isNearAccessPointWithBSSID bssidB: String) -> Bool
    {
        guard let neighbors = wifiAccessPointsGraph.neighborsForVertex(bssidA) else { return false }
        
        for neighbor in neighbors
        {
            if neighbor == bssidB { return true }
            
            for neighbor2 in wifiAccessPointsGraph.neighborsForVertex(neighbor)!
            {
                if neighbor2 == bssidB { return true }
            }
        }
        
        return false
    }
    
    static func currentBSSID() -> String?
    {
        guard let reachability = try? Reachability.reachabilityForLocalWiFi() where reachability.currentReachabilityStatus == .ReachableViaWiFi && TARGET_OS_SIMULATOR == 0 else { return nil }
        
        if let interfaces:CFArray! = CNCopySupportedInterfaces() where CFArrayGetCount(interfaces) > 0
        {
            let interfaceName: UnsafePointer<Void> = CFArrayGetValueAtIndex(interfaces, 0)
            let rec = unsafeBitCast(interfaceName, AnyObject.self)
            
            if let unsafeInterfaceData = CNCopyCurrentNetworkInfo(String(rec))
            {
                let interfaceData = unsafeInterfaceData as Dictionary
                return (interfaceData["BSSID"] as? String)?.uppercaseString
            }
        }
        
        return nil
    }
    
    func reportCurrentBSSIDAndFetchUpdatesForFriendsLocationsWithSuccessHandler(completionHandler: (status: ProximityManagerReportingCompletionStatus) -> ())
    {
        NSUserDefaults.standardUserDefaults().setDouble(NSDate().timeIntervalSince1970, forKey: "lastBackgroundUpdate")
        
        guard let currentBSSID = ProximityManager.currentBSSID() else
        {
            completionHandler(status: .NotConnectedToWifi)
            return
        }
        
        enHueco.appUser.currentBSSID = currentBSSID
        
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.LocationReportSegment)!)
        request.setValue(enHueco.appUser.username, forHTTPHeaderField: EHParameters.UserID)
        request.setValue(enHueco.appUser.token, forHTTPHeaderField: EHParameters.Token)
        request.HTTPMethod = "PUT"
        
        let params = ["bssid" : currentBSSID]
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: params, onSuccess: { (JSONResponse) -> () in
            
            for friendDictionary in JSONResponse as! [[String : AnyObject]]
            {
                enHueco.appUser.friends[ friendDictionary["login"] as! String ]?.currentBSSID = (friendDictionary["location"]!["bssid"] as! String).uppercaseString
            }
                    
            NSUserDefaults.standardUserDefaults().setDouble(NSDate().timeIntervalSince1970, forKey: "lastBackgroundUpdateResponse")
            
            dispatch_async(dispatch_get_main_queue())
            {
                NSNotificationCenter.defaultCenter().postNotificationName(EHProximityManagerNotification.ProximityManagerDidReceiveProximityUpdates, object: self)
            }
            
            completionHandler(status: .Success)
            
        }) { (error) -> () in
            
            completionHandler(status: .NetworkFailure)
        }
    }
    
    func updateBackgroundFetchInterval()
    {
        if NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.shareLocationWithCloseFriends) || NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.nearbyCloseFriendsNotifications)
        {
            let (currentFreeTimePeriod, nextFreeTimePeriod) = enHueco.appUser.currentAndNextFreeTimePeriods()
            
            if currentFreeTimePeriod != nil
            {
                //Ask iOS to kindly try to wake up the app frequently during free time periods.
                UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(ProximityManager.backgroundFetchIntervalDuringFreeTimePeriods)
                print("Reprogramming fetch interval: Continuous")
            }
            else if let nextFreeTimePeriod = nextFreeTimePeriod
            {
                //If the user is not free ask iOS to try to wake up app as soon as user becomes free.
                UIApplication.sharedApplication().setMinimumBackgroundFetchInterval( nextFreeTimePeriod.startHourInDate(NSDate()).timeIntervalSinceNow )
                print("Reprogramming fetch interval: In \(nextFreeTimePeriod.startHourInDate(NSDate()).timeIntervalSinceNow/60) minutes")
            }
            else
            {
                //The day is over, user doesn't have more free time periods ahead, we're going to preserve their battery life by asking iOS to try to wake app less frequently
                UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(ProximityManager.backgroundFetchIntervalAfterDayOver)
                print("Reprogramming fetch interval: After day over")
            }
        }
        else
        {
            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
        }
    }
}
