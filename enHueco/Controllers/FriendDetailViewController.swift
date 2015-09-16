//
//  ViewFriendViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 9/8/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class FriendDetailViewController: UIViewController
{
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
   
    var friend : User!
    var recordId : NSNumber?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        nameLabel.text = friend.firstNames
        userNameLabel.text = friend.username
        
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.barTintColor = EHIntefaceColor.mainInterfaceColor
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()

        setRecordId()
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        navigationController!.navigationBarHidden = false
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func whatsappMessage(sender: UIButton)
    {
        let url: NSURL = NSURL(string: "whatsapp://send?" + ((self.recordId == nil) ? "": "abid=\(self.recordId!)"))!
        UIApplication.sharedApplication().openURL(url)
        
    }
    
    @IBAction func viewSchedule(sender: UIButton)
    {
        let scheduleCalendar = storyboard?.instantiateViewControllerWithIdentifier("ScheduleViewController") as!ScheduleViewController
        scheduleCalendar.user = friend
        presentViewController(scheduleCalendar, animated: true, completion: nil)
    }
    
    @IBAction func call(sender: UIButton)
    {
        if let num = friend.phoneNumber
        {
            let url:NSURL = NSURL(string: "tel://\(num)")!
            UIApplication.sharedApplication().openURL(url)
        }
    }

    func setRecordId()
    {
        if self.friend.phoneNumber.characters.count < 7
        {
            self.recordId = nil
            return
        }
        let addressBook = APAddressBook()
        addressBook.fieldsMask =  APContactField.Phones.union(APContactField.RecordID)
        addressBook.loadContacts(
            { (contacts: [AnyObject]!, error: NSError!) in
                if contacts != nil {
                    for contact in contacts
                    {
                        if let contactAP = contact as? APContact
                        {
                            for phone in contactAP.phones
                            {
                                if var phoneString = phone as? String
                                {
                                    phoneString = phoneString.stringByReplacingOccurrencesOfString("(", withString: "")
                                    phoneString = phoneString.stringByReplacingOccurrencesOfString(")", withString: "")
                                    phoneString = phoneString.stringByReplacingOccurrencesOfString("-", withString: "")
                                    phoneString = phoneString.stringByReplacingOccurrencesOfString(" ", withString: "")
                                    phoneString = phoneString.stringByReplacingOccurrencesOfString("+", withString: "")
                                    phoneString = phoneString.stringByReplacingOccurrencesOfString(" ", withString: "")
                                    print(phoneString)
                                    if phoneString.rangeOfString(self.friend.phoneNumber) != nil{
                                        self.recordId = contactAP.recordID
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
                else if (error != nil) {
                    self.recordId = nil
                }
                self.recordId = nil
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
