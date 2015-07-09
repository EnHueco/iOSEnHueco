//
//  MeViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 1/24/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import UIKit

class MeViewController: UIViewController, AppControllerDelegate{

    @IBOutlet weak var myPicture: UIImageView!
    @IBOutlet weak var myUsername: UILabel!
    @IBOutlet weak var myName: UILabel!
    @IBOutlet weak var editSchedule: UIButton!
    
    var app : AppController?
    
    
    override func viewWillAppear(animated: Bool) {
        app =  AppController(delegate: self)
        var user = app?.getLocalAndUpdateRemoteAppUser()
        updateFields(user!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateFields(user:AppUser){
        
        if var username = user.login?{
            self.myUsername.text = username
        }
        if var firstNames = user.firstNames?{
            self.myName.text = firstNames
        }
        self.view.setNeedsDisplay()

    }

    func AppControllerValidResponseReceived()
    {
        var user = app?.getLocalAppUser()
        updateFields(user!)
        
    }
    func AppControllerInvalidResponseReceived(errorResponse:NSString)
    {
        
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
