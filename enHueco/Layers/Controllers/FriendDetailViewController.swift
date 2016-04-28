//
//  ViewFriendViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 9/8/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class FriendDetailViewController: UIViewController, UIPopoverPresentationControllerDelegate, PopOverMenuViewControllerDelegate
{
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var firstNamesLabel: UILabel!
    @IBOutlet weak var lastNamesLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var viewScheduleButton: UIButton!
    @IBOutlet weak var commonFreeTimePeriodsButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
       
    var dotsBarButtonItem: UIBarButtonItem!
    
    var friend : User!

    var recordId : NSNumber?
    
    let localizableStringsFile = "Friends"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = friend.firstNames
        
        viewScheduleButton.backgroundColor = EHInterfaceColor.defaultBigRoundedButtonsColor
        commonFreeTimePeriodsButton.backgroundColor = EHInterfaceColor.defaultBigRoundedButtonsColor
        
        firstNamesLabel.text = friend.firstNames
        lastNamesLabel.text = friend.lastNames
        userNameLabel.text = friend.username
        
        setRecordId()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        view.addSubview(activityIndicator)
        activityIndicator.autoAlignAxis(.Horizontal, toSameAxisOfView: imageImageView)
        activityIndicator.autoAlignAxis(.Vertical, toSameAxisOfView: imageImageView)
        activityIndicator.startAnimating()

        dispatch_async(dispatch_get_main_queue())
        {
            self.imageImageView.sd_setImageWithURL(self.friend.imageURL, placeholderImage: nil, options: [.AvoidAutoSetImage, .HighPriority, .RefreshCached, .RetryFailed], completed: { (image, error, cacheType, _) in
                
                activityIndicator.removeFromSuperview()
                
                guard let image = image else { return }
                
                UIView.transitionWithView(self.imageImageView, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    
                    self.imageImageView.image = image
                    
                }, completion: nil)
                
                UIView.transitionWithView(self.backgroundImageView, duration: 1, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    
                    self.backgroundImageView.image = image.applyBlurWithRadius(40, tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
                    
                }, completion: nil)
                
                self.updateButtonColors()
            })
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
        
        commonFreeTimePeriodsButton.clipsToBounds = true
        commonFreeTimePeriodsButton.layer.cornerRadius = viewScheduleButton.frame.height / 2
        
        imageImageView.clipsToBounds = true
        imageImageView.layer.cornerRadius = imageImageView.frame.height/2
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        transitionCoordinator()?.animateAlongsideTransition({ (context) -> Void in
            
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.barTintColor = UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha: 0.6)
            
        }, completion: { (context) -> Void in
            
            if !context.isCancelled()
            {
                UIView.animateWithDuration(0.3)
                {
                    self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha: 0.6)), forBarMetrics: .Default)
                }
            }
            else
            {
                self.navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor
                self.navigationController?.navigationBar.shadowImage = UIImage()
            }
        })
        
        let dotsButton = UIButton(type: .Custom)
        dotsButton.frame.size = CGSize(width: 20, height: 20)
        dotsButton.setBackgroundImage(UIImage(named: "Dots")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        dotsButton.addTarget(self, action: #selector(FriendDetailViewController.dotsIconPressed(_:)), forControlEvents: .TouchUpInside)
        dotsButton.tintColor = UIColor.whiteColor()
        
        dotsBarButtonItem = UIBarButtonItem(customView: dotsButton)
        
        navigationItem.rightBarButtonItem = dotsBarButtonItem
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateButtonColors()
    {
        let averageImageColor = UIColor(contrastingBlackOrWhiteColorOn: UIColor(averageColorFromImage: imageImageView.image), isFlat: true, alpha: 0.4)
        
        UIView.animateWithDuration(0.8)
        {
            self.viewScheduleButton.backgroundColor = averageImageColor
            self.commonFreeTimePeriodsButton.backgroundColor = averageImageColor
        }
    }
    
    func dotsIconPressed(sender: UIButton)
    {
        let menu = storyboard!.instantiateViewControllerWithIdentifier("PopOverMenuViewController") as! PopOverMenuViewController
        
        menu.titlesAndIcons = [("Call".localizedUsingGeneralFile(), UIImage(named: "Phone")!), ("WhatsApp", UIImage(named: "WhatsApp")!), ("Options".localizedUsingGeneralFile(), UIImage(named: "sliders")!)]
        menu.tintColor = UIColor(white: 1, alpha: 0.8)
        menu.delegate = self
        
        menu.modalInPopover = true
        menu.modalPresentationStyle = .Popover
        menu.popoverPresentationController?.delegate = self
        menu.popoverPresentationController?.barButtonItem = dotsBarButtonItem
        menu.popoverPresentationController?.backgroundColor = UIColor(white: 0.80, alpha: 0.35)
        
        presentViewController(menu, animated: true, completion: nil)        
    }
    
    func popOverMenuViewController(controller: PopOverMenuViewController, didSelectMenuItemAtIndex index: Int)
    {
        if let number = friend.phoneNumber where index == 0
        {
            enHueco.callFriend(number)
            
            controller.dismissViewControllerAnimated(true, completion: nil)
        }
        else if let recordId = recordId where index == 1
        {
            enHueco.whatsappMessageTo(recordId)
            
            controller.dismissViewControllerAnimated(true, completion: nil)
        }
        else if index == 2
        {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            alertController.addAction(UIAlertAction(title: "DeleteFriend".localizedUsingFile(localizableStringsFile), style: .Destructive, handler: { (action) -> Void in
                
                EHProgressHUD.showSpinnerInView(self.view)
                FriendsManager.sharedManager.deleteFriend(self.friend, completionHandler: { (success, error) -> () in
                    
                    EHProgressHUD.dismissSpinnerForView(self.view)

                    guard success && error == nil else {
                        
                        EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                        return
                    }
                    
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel".localizedUsingGeneralFile(), style: .Cancel, handler: nil))
            
            controller.dismissViewControllerAnimated(true, completion: nil)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .None
    }
    
    @IBAction func whatsappMessage(sender: UIButton)
    {
        enHueco.whatsappMessageTo(self.recordId!)
    }
    
    @IBAction func viewSchedule(sender: UIButton)
    {
        let scheduleCalendar = storyboard?.instantiateViewControllerWithIdentifier("ScheduleViewController") as!ScheduleViewController
        scheduleCalendar.schedule = friend.schedule
        presentViewController(scheduleCalendar, animated: true, completion: nil)
    }
    
    @IBAction func commonFreeTimePeriodsButtonPressed(sender: AnyObject)
    {
        let commonFreeTimePeriodsViewController = storyboard?.instantiateViewControllerWithIdentifier("CommonFreeTimePeriodsViewController") as! CommonFreeTimePeriodsViewController
        commonFreeTimePeriodsViewController.initialFriend = friend
        
        navigationController?.pushViewController(commonFreeTimePeriodsViewController, animated: true)
    }

    @IBAction func call(sender: UIButton)
    {
        if let num = friend.phoneNumber
        {
            enHueco.callFriend(num)
        }
    }

    func setRecordId()
    {
        if self.friend.phoneNumber.characters.count < 7
        {
            self.recordId = nil
        }
        else
        {
            enHueco.getFriendABID(self.friend.phoneNumber, completionHandler:{ (abid) -> () in
                self.recordId = abid
            })
        }
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
