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
                let interfaceData = unsafeInterfaceData as Dictionary!
                return interfaceData["BSSID"] as? String
            }
        }
        
        return nil
    }
    
    func reportCurrentBSSIDAndFetchUpdatesForFriendsLocationsWithSuccessHandler(successHandler: () -> (), networkFailureHandler: () -> (), notConnectedToWifiHandler: () -> ())
    {
        
    }
}
