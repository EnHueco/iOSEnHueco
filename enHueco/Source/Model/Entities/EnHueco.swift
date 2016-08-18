//
//  EnHueco.swift
//  enHueco
//
//  Created by Diego Montoya on 7/15/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation
import CoreLocation
import SystemConfiguration.CaptiveNetwork
import APAddressBook

/// Universally accessible singleton instance
let enHueco = EnHueco()

/** Stateful singleton entry point
 
 The singleton is intended to store all aplication's model state which should be persisted in order for 
 it to be restored in case the application is opened in an offline environment.
*/
class EnHueco
{            
    /// User of the app
    var appUser: AppUser!
    
    private init()
    {
        
    }
    
    /*
    // TODO: Move, doesn't belong here
    func createTestAppUser ()
    {
        //Pruebas
        
        appUser = AppUser(username: "pa.perez10", firstNames: "Diego", lastNames: "Montoya Sefair", phoneNumber: "3176694189", imageURL: NSURL(string: "https://fbcdn-sphotos-a-a.akamaihd.net/hphotos-ak-xap1/t31.0-8/1498135_821566567860780_1633731954_o.jpg")!, imageThumbnailURL : NSURL(string: "https://fbcdn-sphotos-a-a.akamaihd.net/hphotos-ak-xap1/t31.0-8/1498135_821566567860780_1633731954_o.jpg")!, ID:"pa.perez10", lastUpdatedOn: NSDate())

        let friend = User(username: "da.gomez11", firstNames: "Diego Alejandro", lastNames: "Gómez Mosquera", phoneNumber: "3176694189", imageURL: NSURL(string: "https://fbcdn-sphotos-e-a.akamaihd.net/hphotos-ak-xat1/v/t1.0-9/1377456_10152974578604740_7067096578609392451_n.jpg?oh=89245c25c3ddaa4f7d1341f7788de261&oe=56925447&__gda__=1448954703_30d0fe175a8ab0b665dc074d63a087d6")!, imageThumbnailURL: nil, ID:"da.gomez11", lastUpdatedOn: NSDate())
        let start = NSDateComponents(); start.hour = 0; start.minute = 00
        let end = NSDateComponents(); end.hour = 1; end.minute = 00
        let gap = Event(type:.FreeTime, startHour: start, endHour: end)
        friend.schedule.weekDays[6].addEvent(gap)
        appUser.friends[friend.username] = friend
        
        appUser.friends[appUser.username] = appUser
        
        appUser.imageURL = nil

        //////////
    }
    
    // TODO: Move, doesn't belong here
    func callFriend(phoneNumber : String)
    {
        let url:NSURL = NSURL(string: "tel://\(phoneNumber)")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    // TODO: Move, doesn't belong here
    func whatsappMessageTo(friendABID : NSNumber?)
    {
        let url: NSURL = NSURL(string: "whatsapp://send?" + ((friendABID == nil) ? "": "abid=\(friendABID!)"))!
        UIApplication.sharedApplication().openURL(url)
    }
    
    // TODO: Move, doesn't belong here
    func getFriendABID(phoneNumber : String, completionHandler : (abid: NSNumber?) -> ())
    {
        let addressBook = APAddressBook()
        addressBook.fieldsMask =  APContactField.Phones.union(APContactField.RecordID)
        
        addressBook.loadContacts({ (contacts: [AnyObject]!, error: NSError!) in
            
            guard let contacts = contacts else
            {
                completionHandler(abid: nil)
                return
            }
            
            for contact in contacts
            {
                guard let contactAP = contact as? APContact else { continue }
                
                for phone in contactAP.phones ?? []
                {
                    guard var phoneString = phone as? String else { continue }
                    
                    phoneString = phoneString.stringByReplacingOccurrencesOfString("(", withString: "")
                    phoneString = phoneString.stringByReplacingOccurrencesOfString(")", withString: "")
                    phoneString = phoneString.stringByReplacingOccurrencesOfString("-", withString: "")
                    phoneString = phoneString.stringByReplacingOccurrencesOfString(" ", withString: "")
                    phoneString = phoneString.stringByReplacingOccurrencesOfString("+", withString: "")
                    phoneString = phoneString.stringByReplacingOccurrencesOfString(" ", withString: "")
                    
                    if phoneString.rangeOfString(phoneNumber) != nil
                    {
                        completionHandler(abid: contactAP.recordID)
                        return
                    }
                }
            }
        })
        return
    }
 */
}