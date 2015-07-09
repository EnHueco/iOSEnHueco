//
//  EditScheduleViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 12/6/14.
//  Copyright (c) 2014 Diego Gómez. All rights reserved.
//

import UIKit

class EditScheduleViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate
{
    @IBOutlet weak var calendarTableView: UITableView!
    
    @IBOutlet weak var calendarTabBar: UITabBar!

    @IBAction func cancel(sender: UIBarButtonItem) {
        self.exit()
    }
    
    @IBAction func saveSchedule(sender: AnyObject) {

    }
    
    
    private func exit()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        

    }
    

    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
    
    
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalConstants.Schedule.hours.count
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell = self.calendarTableView.dequeueReusableCellWithIdentifier("hour") as UITableViewCell
        cell.textLabel?.text = GlobalConstants.Schedule.hours[indexPath.row]
//        cell?.description =
        return cell
    }
    
    
    
}

