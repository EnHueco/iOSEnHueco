//
//  ViewFriendViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 9/8/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class FriendDetailViewController: UIViewController, UIPopoverPresentationControllerDelegate, PopOverMenuViewControllerDelegate {
    
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var firstNamesLabel: UILabel!
    @IBOutlet weak var lastNamesLabel: UILabel!
    @IBOutlet weak var viewScheduleButton: UIButton!
    @IBOutlet weak var commonFreeTimePeriodsButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!

    fileprivate var dotsBarButtonItem: UIBarButtonItem!
    
    /// The ID of the friend to display
    var friendID: String?

    // Real-time logic manager (If view visible)
    fileprivate var realtimeFriendManager: RealtimeUserManager?

    fileprivate var recordId: NSNumber?

    let localizableStringsFile = "Friends"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        viewScheduleButton.clipsToBounds = true
        viewScheduleButton.layer.cornerRadius = viewScheduleButton.frame.height / 2

        commonFreeTimePeriodsButton.clipsToBounds = true
        commonFreeTimePeriodsButton.layer.cornerRadius = viewScheduleButton.frame.height / 2

        imageImageView.clipsToBounds = true
        imageImageView.layer.cornerRadius = imageImageView.frame.height / 2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let friendID = friendID {
            realtimeFriendManager = RealtimeUserManager(userID: friendID, delegate: self)
        }

        navigationController?.setNavigationBarHidden(false, animated: true)

        transitionCoordinator?.animate(alongsideTransition: {
            (context) -> Void in

            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.barTintColor = UIColor(red: 57 / 255.0, green: 57 / 255.0, blue: 57 / 255.0, alpha: 0.6)

        }, completion: {
            (context) -> Void in

            if !context.isCancelled {
                UIView.animate(withDuration: 0.3, animations: {
                    self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor(red: 57 / 255.0, green: 57 / 255.0, blue: 57 / 255.0, alpha: 0.6)), for: .default)
                }) 
            } else {
                self.navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor
                self.navigationController?.navigationBar.shadowImage = UIImage()
            }
        })

        let dotsButton = UIButton(type: .custom)
        dotsButton.frame.size = CGSize(width: 20, height: 20)
        dotsButton.setBackgroundImage(UIImage(named: "Dots")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        dotsButton.addTarget(self, action: #selector(FriendDetailViewController.dotsIconPressed(_:)), for: .touchUpInside)
        dotsButton.tintColor = UIColor.white

        dotsBarButtonItem = UIBarButtonItem(customView: dotsButton)

        navigationItem.rightBarButtonItem = dotsBarButtonItem
    }

    func refreshUIData() {
        
        guard let friend = realtimeFriendManager?.user else {
            return
        }
        
        title = friend.firstNames
        
        viewScheduleButton.backgroundColor = EHInterfaceColor.defaultBigRoundedButtonsColor
        commonFreeTimePeriodsButton.backgroundColor = EHInterfaceColor.defaultBigRoundedButtonsColor
        
        firstNamesLabel.text = friend.firstNames
        lastNamesLabel.text = friend.lastNames
        
        setRecordId()
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        view.addSubview(activityIndicator)
        activityIndicator.autoAlignAxis(.horizontal, toSameAxisOf: imageImageView)
        activityIndicator.autoAlignAxis(.vertical, toSameAxisOf: imageImageView)
        activityIndicator.startAnimating()
        
        DispatchQueue.main.async {
            self.imageImageView.sd_setImage(with: friend.image as URL!, placeholderImage: nil, options: [.avoidAutoSetImage, .highPriority, .refreshCached, .retryFailed], completed: {
                (image, error, cacheType, _) in
                
                activityIndicator.removeFromSuperview()
                
                guard let image = image else {
                    return
                }
                
                UIView.transition(with: self.imageImageView, duration: 1, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    
                    self.imageImageView.image = image
                    
                    }, completion: nil)
                
                UIView.transition(with: self.backgroundImageView, duration: 1, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    
                    self.backgroundImageView.image = image.applyBlur(withRadius: 40, tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
                    
                    }, completion: nil)
                
                self.updateButtonColors()
            })
        }
        
        imageImageView.contentMode = .scaleAspectFill
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateButtonColors() {

        let averageImageColor = UIColor(contrastingBlackOrWhiteColorOn: UIColor(averageColorFrom: imageImageView.image!), isFlat: true, alpha: 0.4)

        UIView.animate(withDuration: 0.8, animations: {
            self.viewScheduleButton.backgroundColor = averageImageColor
            self.commonFreeTimePeriodsButton.backgroundColor = averageImageColor
        }) 
    }

    func dotsIconPressed(_ sender: UIButton) {

        let menu = storyboard!.instantiateViewController(withIdentifier: "PopOverMenuViewController") as! PopOverMenuViewController

        menu.titlesAndIcons = [("Call".localizedUsingGeneralFile(), UIImage(named: "Phone")!), ("WhatsApp", UIImage(named: "WhatsApp")!), ("Options".localizedUsingGeneralFile(), UIImage(named: "sliders")!)]
        menu.tintColor = UIColor(white: 1, alpha: 0.8)
        menu.delegate = self

        menu.isModalInPopover = true
        menu.modalPresentationStyle = .popover
        menu.popoverPresentationController?.delegate = self
        menu.popoverPresentationController?.barButtonItem = dotsBarButtonItem
        menu.popoverPresentationController?.backgroundColor = UIColor(white: 0.80, alpha: 0.35)

        present(menu, animated: true, completion: nil)
    }

    func popOverMenuViewController(_ controller: PopOverMenuViewController, didSelectMenuItemAtIndex index: Int) {

        guard let friend = realtimeFriendManager?.user else { return }
        
        let appDelegate = AppDelegate.sharedDelegate
        
        if let number = friend.phoneNumber, index == 0 {
            
            appDelegate.callFriend(number)
            controller.dismiss(animated: true, completion: nil)
            
        } else if let recordId = recordId, index == 1 {
            
            appDelegate.whatsappMessageTo(recordId)
            controller.dismiss(animated: true, completion: nil)
            
        } else if index == 2 {
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            alertController.addAction(UIAlertAction(title: "DeleteFriend".localizedUsingFile(localizableStringsFile), style: .destructive, handler: {
                (action) -> Void in

                EHProgressHUD.showSpinnerInView(self.view)
                FriendsManager.sharedManager.deleteFriend(id: friend.id, completionHandler: { (error) in
                    EHProgressHUD.dismissSpinnerForView(self.view)

                    guard error == nil else {
                        EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                        return
                    }

                    self.navigationController?.popViewController(animated: true)
                })
            }))

            alertController.addAction(UIAlertAction(title: "Cancel".localizedUsingGeneralFile(), style: .cancel, handler: nil))

            controller.dismiss(animated: true, completion: nil)
            present(alertController, animated: true, completion: nil)
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {

        return .none
    }

    @IBAction func viewSchedule(_ sender: UIButton) {

        guard let friendID = friendID else {
            assertionFailure()
            return
        }
        
        let scheduleCalendar = storyboard?.instantiateViewController(withIdentifier: "ScheduleViewController") as! ScheduleViewController
        scheduleCalendar.userID = friendID
        present(scheduleCalendar, animated: true, completion: nil)
    }

    @IBAction func commonFreeTimePeriodsButtonPressed(_ sender: AnyObject) {

        let commonFreeTimePeriodsViewController = storyboard?.instantiateViewController(withIdentifier: "CommonFreeTimePeriodsViewController") as! CommonFreeTimePeriodsViewController
        commonFreeTimePeriodsViewController.initialFriendID = friendID

        navigationController?.pushViewController(commonFreeTimePeriodsViewController, animated: true)
    }

    func setRecordId() {

        guard let friend = realtimeFriendManager?.user, let phoneNumber = friend.phoneNumber else { return }
        
        if phoneNumber.characters.count < 7 {
            recordId = nil
            
        } else {
            AppDelegate.sharedDelegate.getFriendABID(phoneNumber, completionHandler: { (abid) -> () in
                self.recordId = abid
            })
        }
    }
}

extension FriendDetailViewController: RealtimeUserManagerDelegate {
    
    func realtimeUserManagerDidReceiveFriendOrFriendScheduleUpdates(_ manager: RealtimeUserManager) {
        refreshUIData()
    }
}
