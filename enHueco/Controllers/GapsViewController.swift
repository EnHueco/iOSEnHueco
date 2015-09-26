//
//  EditGapsTableViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 9/8/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class GapsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var gapsTableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        gapsTableView.dataSource = self
        gapsTableView.delegate = self
        
        let start = NSDateComponents();
        start.hour = 10
        start.minute = 30
        
        let end = NSDateComponents();
        end.hour = 1
        end.minute = 30
        system.appUser.schedule.weekDays[0].addGap(Gap(daySchedule: system.appUser.schedule.weekDays[0], startHour:  start, endHour: end))
        
        navigationController!.navigationBar.barStyle = UIBarStyle.Black
        navigationController!.navigationBar.barTintColor = EHIntefaceColor.mainInterfaceColor
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 5
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return system.appUser.schedule.weekDays[section].gaps.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        var sectionName : String
        
        switch section
        {
            case 0:
                sectionName = "Lunes"
            case 1:
                sectionName = "Martes"
            case 2:
                sectionName = "Miercoles"
            case 3:
                sectionName = "Jueves"
            case 4:
                sectionName = "Viernes"
            default:
                sectionName = ""
        }
        
        if system.appUser.schedule.weekDays[section].gaps.count == 0
        {
            sectionName = ""
        }
        
        return sectionName
    }
    
    func dismissViewController (sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let gap = system.appUser.schedule.weekDays[indexPath.section].gaps[indexPath.row]
        let cell = gapsTableView.dequeueReusableCellWithIdentifier("GapsCell") as! GapCell
        
        cell.startHourLabel.text = "\(gap.startHour.hour):\(gap.startHour.minute)"
        cell.endHourLabel.text = "\(gap.endHour.hour):\(gap.endHour.minute)"
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let gap = system.appUser.schedule.weekDays[indexPath.section].gaps[indexPath.row]
        let gapEditView  = storyboard?.instantiateViewControllerWithIdentifier("AddViewGapViewController") as! AddViewGapViewController
        gapEditView.eventToEdit = gap
        
        navigationController!.pushViewController(gapEditView, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
