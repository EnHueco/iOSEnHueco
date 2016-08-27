//
//  PopOverMenuViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 12/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import PureLayout

@objc protocol PopOverMenuViewControllerDelegate: class {
    optional func popOverMenuViewController(controller: PopOverMenuViewController, didSelectMenuItemAtIndex index: Int)
}

class PopOverMenuViewController: UITableViewController, UIGestureRecognizerDelegate {
    private var tapOutsideRecognizer: UITapGestureRecognizer!

    weak var delegate: PopOverMenuViewControllerDelegate?

    var titlesAndIcons = [(String, UIImage)]()
    var tintColor: UIColor?

    private let rowHeight: CGFloat = 44.0

    override func viewDidLoad() {
        super.viewDidLoad()

        preferredContentSize = CGSize(width: 160, height: rowHeight * CGFloat(titlesAndIcons.count))
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if tapOutsideRecognizer == nil {
            tapOutsideRecognizer = UITapGestureRecognizer(target: self, action: #selector(PopOverMenuViewController.handleTapBehind(_:)))
            tapOutsideRecognizer.numberOfTapsRequired = 1
            tapOutsideRecognizer.cancelsTouchesInView = false
            tapOutsideRecognizer.delegate = self
            view.window?.addGestureRecognizer(tapOutsideRecognizer)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if tapOutsideRecognizer != nil {
            view.window?.removeGestureRecognizer(tapOutsideRecognizer)
            tapOutsideRecognizer = nil
        }
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return titlesAndIcons.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let (title, icon) = titlesAndIcons[indexPath.row]

        let cell = tableView.dequeueReusableCellWithIdentifier("PopOverMenuTableViewCell") as! PopOverMenuTableViewCell

        cell.iconImageView.image = icon.imageWithRenderingMode(.AlwaysTemplate)
        cell.titleLabel.text = title

        cell.iconImageView.tintColor = tintColor ?? UIColor.blackColor()
        cell.titleLabel.textColor = tintColor ?? UIColor.blackColor()

        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        return rowHeight
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        delegate?.popOverMenuViewController?(self, didSelectMenuItemAtIndex: indexPath.row)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func handleTapBehind(sender: UITapGestureRecognizer) {

        if sender.state == UIGestureRecognizerState.Ended {
            let location: CGPoint = sender.locationInView(nil)

            if !view.pointInside(view.convertPoint(location, fromView: view.window), withEvent: nil) {
                view.window?.removeGestureRecognizer(sender)
                dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return true
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
