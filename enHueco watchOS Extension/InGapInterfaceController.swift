//
//  InterfaceController.swift
//  enHueco watchOS Extension
//
//  Created by Diego Montoya Sefair on 10/31/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InGapInterfaceController: WKInterfaceController
{
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var noFriendsInGapLabel: WKInterfaceLabel!

    var friendsInGap = [[String : Any]]()
    
    override func awakeWithContext(context: Any?)
    {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        fetchAndUpdateDataIfNeeded()
    }
    
    func fetchAndUpdateDataIfNeeded()
    {
        WCSession.defaultSession().sendMessage(["request":"friendsCurrentlyInGap"], replyHandler: { (response: [String : Any]) -> Void in
            
            var friendsInGap = response["friends"] as! [Any]
            self.friendsInGap = friendsInGap as! [[String : Any]]
            
            self.table.setNumberOfRows(friendsInGap.count, withRowType: "InGapCell")
            
            if !friendsInGap.isEmpty { self.noFriendsInGapLabel.setHidden(true) }
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "hh:mm a"
            
            for (i, friend) in friendsInGap.enumerate()
            {
                let controller = self.table.rowControllerAtIndex(i) as! InGapRowController
                
                controller.friendNameLabel.setText(friend["name"] as? String)
                controller.timeLabel.setText(formatter.stringFromDate(friend["gapEndDate"] as! NSDate))
                
                let conf = NSURLSessionConfiguration.defaultSessionConfiguration()
                let session = NSURLSession(configuration: conf)
                
                let task = session.dataTaskWithURL(NSURL(string: friend["imageURL"] as! String)!) { (data, res, error) -> Void in
                    
                    if let data = data where error == nil
                    {
                        dispatch_async(dispatch_get_main_queue())
                        {
                            self.friendsInGap[i]["imageData"] = data
                            controller.friendImageImageView.setImageData(data)
                        }
                    }
                }
                
                task.resume()
            }
            
        }) { (error) -> Void in
                
            print(error)
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> Any?
    {
        return friendsInGap[rowIndex]
    }

    override func didDeactivate()
    {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()        
    }
}
