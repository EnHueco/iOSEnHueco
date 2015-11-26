//
//  ProximityManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 11/3/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation
import NetworkExtension
import SystemConfiguration.CaptiveNetwork
import ReachabilitySwift

class ProximityManager: NSObject
{
    static private var instance = ProximityManager()
    
    static let backgroundFetchIntervalDuringGaps = 5*60.0
    static let backgroundFetchIntervalAfterDayOver = 7*3600.0
    
    ///Graph with BSSIDs of the access points
    private let wifiAccessPointsGraph = UnweightedGraph<String>()
    
    private override init()
    {
        super.init()
    }
    
    static func sharedManager() -> ProximityManager
    {
        return instance
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
        for neighbor in wifiAccessPointsGraph.neighborsForVertex(bssidA)!
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
        guard let reachability = try? Reachability.reachabilityForLocalWiFi() where reachability.currentReachabilityStatus == .ReachableViaWiFi else { return nil }
        
        if let interfaces:CFArray! = CNCopySupportedInterfaces() where CFArrayGetCount(interfaces) > 0
        {
            let interfaceName: UnsafePointer<Void> = CFArrayGetValueAtIndex(interfaces, 0)
            let rec = unsafeBitCast(interfaceName, AnyObject.self)
            
            if let unsafeInterfaceData = CNCopyCurrentNetworkInfo(String(rec))
            {
                let interfaceData = unsafeInterfaceData as Dictionary
                return interfaceData["BSSID"] as? String
            }
        }
        
        return nil
    }
    
    func reportCurrentBSSIDAndFetchUpdatesForFriendsLocationsWithSuccessHandler(successHandler: () -> (), networkFailureHandler: () -> (), notConnectedToWifiHandler: () -> ())
    {
        NSUserDefaults.standardUserDefaults().setDouble(NSDate().timeIntervalSince1970, forKey: "lastBackgroundUpdate")
        
        guard let currentBSSID = ProximityManager.currentBSSID() else
        {
            notConnectedToWifiHandler()
            return
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: EHURLS.Base + EHURLS.LocationReportSegment)!)
        request.setValue(system.appUser.username, forHTTPHeaderField: EHParameters.UserID)
        request.setValue(system.appUser.token, forHTTPHeaderField: EHParameters.Token)
        request.HTTPMethod = "PUT"
        
        let params = ["location" : currentBSSID]
        
        ConnectionManager.sendAsyncRequest(request, withJSONParams: params, onSuccess: { (JSONResponse) -> () in
            
            for friendDictionary in JSONResponse as! [[String : AnyObject]]
            {
                system.appUser.friends[ friendDictionary["login"] as! String ]?.currentBSSID = (friendDictionary["location"]!["bssid"] as! String)
            }
            
            successHandler()
            
        }) { (error) -> () in
            
            networkFailureHandler()
        }
    }
    
    func updateBackgroundFetchIntervalBecauseUserChangedLocationSharingSettings()
    {
        if NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.shareLocationWithCloseFriends) || NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.nearbyCloseFriendsNotifications)
        {
            let (currentGap, nextGap) = system.appUser.currentAndNextGap()
            
            if currentGap != nil
            {
                //Ask iOS to kindly try to wake up the app frequently during gaps.
                UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(ProximityManager.backgroundFetchIntervalDuringGaps)
            }
            else if let nextGap = nextGap
            {
                //If the user is not in gap ask iOS to try to wake up app as soon as user becomes free.
                UIApplication.sharedApplication().setMinimumBackgroundFetchInterval( nextGap.endHourInDate(NSDate()).timeIntervalSinceNow )
            }
            else
            {
                //The day is over, user doesn't have more gaps ahead, we're going to preserve their battery life by asking iOS to try to wake app less frequently
                UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(ProximityManager.backgroundFetchIntervalAfterDayOver)
            }
        }
        else
        {
            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
        }
    }
}
