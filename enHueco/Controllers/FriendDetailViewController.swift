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
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var firstNamesLabel: UILabel!
    @IBOutlet weak var lastNamesLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var viewScheduleButton: UIButton!
    @IBOutlet weak var commonGapsButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
   
    var friend : User!
    var recordId : NSNumber?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = friend.firstNames
        
        firstNamesLabel.text = friend.firstNames
        lastNamesLabel.text = friend.lastNames
        userNameLabel.text = friend.username
        
        setRecordId()
        
        backgroundImageView.alpha = 0
        
        dispatch_async(dispatch_get_main_queue())
        {
            self.imageImageView.sd_setImageWithURL(self.friend.imageURL)
            self.backgroundImageView.sd_setImageWithURL(self.friend.imageURL)
            { (_, _, _, _) -> Void in
                
                UIView.animateWithDuration(0.4)
                {
                    self.backgroundImageView.image = self.backgroundImageView.image!.applyBlurWithRadius(40, tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
                    self.backgroundImageView.alpha = 1
                }
            }
        }
        
        imageImageView.contentMode = .ScaleAspectFill
        backgroundImageView.contentMode = .ScaleAspectFill
        backgroundImageView.clipsToBounds = true
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        viewScheduleButton.clipsToBounds = true
        viewScheduleButton.layer.cornerRadius = viewScheduleButton.frame.height/2
        
        commonGapsButton.clipsToBounds = true
        commonGapsButton.layer.cornerRadius = viewScheduleButton.frame.height/2
        
        imageImageView.clipsToBounds = true
        imageImageView.layer.cornerRadius = imageImageView.frame.height/2
    }
    
    override func viewWillAppear(animated: Bool)
    {
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.barTintColor = EHIntefaceColor.mainInterfaceColor
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
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
        scheduleCalendar.schedule = friend.schedule
        presentViewController(scheduleCalendar, animated: true, completion: nil)
    }
    
    @IBAction func commonGapsButtonPressed(sender: AnyObject)
    {
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
                
                if contacts != nil
                {
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
                                    
                                    if phoneString.rangeOfString(self.friend.phoneNumber) != nil
                                    {
                                        self.recordId = contactAP.recordID
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
                else if (error != nil)
                {
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
