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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        nameLabel.text = friend.firstNames
        userNameLabel.text = friend.username
        
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.barTintColor = EHIntefaceColor.mainInterfaceColor
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
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
        let url: NSURL = NSURL(string: "whatsapp://send?text=Hello%2C%20World!")!
        UIApplication.sharedApplication().openURL(url)
        
    }
    
    @IBAction func call(sender: UIButton)
    {
        if let num = friend.phoneNumber
        {
            let url:NSURL = NSURL(string: "tel://\(num)")!
            UIApplication.sharedApplication().openURL(url)
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
