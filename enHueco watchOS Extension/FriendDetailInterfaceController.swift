//
//  FriendDetailInterfaceController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 11/1/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import WatchKit
import Foundation


class FriendDetailInterfaceController: WKInterfaceController
{
    @IBOutlet var friendImageImageView: WKInterfaceImage!
    @IBOutlet var friendNameLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        friendNameLabel.setText(context!["name"] as? String)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "hh:mm a"
        timeLabel.setText(formatter.stringFromDate(context!["gapEndDate"] as! NSDate))
        
        friendImageImageView.setImageData(context!["imageData"] as! NSData)
    }

    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate()
    {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
