//
//  ScheduleViewController.swift
//  enHueco
//
//  Created by Diego on 9/12/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController
{
    /**
        Schedule to be displayed. Defaults to AppUser's
    */
    var schedule: Schedule = system.appUser.schedule

    @IBOutlet weak var importCalendarButton: UIButton!
    @IBOutlet weak var addGapOrClassButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        addGapOrClassButton.clipsToBounds = true
        addGapOrClassButton.layer.cornerRadius = addGapOrClassButton.frame.size.height/2
    }
    
    override func viewWillAppear(animated: Bool)
    {
        navigationController?.navigationBarHidden = true
       
        if schedule !== system.appUser.schedule
        {
            importCalendarButton.hidden = true
            addGapOrClassButton.hidden = true
        }
    }
    
    @IBAction func importScheduleButtonPressed(sender: AnyObject)
    {
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("SelectCalendarViewController") as! SelectCalendarViewController
        navigationController!.pushViewController(controller, animated: true)
    }
    
    @IBAction func cancel(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let controller = segue.destinationViewController as? ScheduleCalendarViewController
        {
            controller.schedule = schedule
        }
    }
}
