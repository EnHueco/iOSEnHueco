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
    @objc optional func popOverMenuViewController(_ controller: PopOverMenuViewController, didSelectMenuItemAtIndex index: Int)
}

class PopOverMenuViewController: UITableViewController, UIGestureRecognizerDelegate {
    fileprivate var tapOutsideRecognizer: UITapGestureRecognizer!

    weak var delegate: PopOverMenuViewControllerDelegate?

    var titlesAndIcons = [(String, UIImage)]()
    var tintColor: UIColor?

    fileprivate let rowHeight: CGFloat = 44.0

    override func viewDidLoad() {
        super.viewDidLoad()

        preferredContentSize = CGSize(width: 160, height: rowHeight * CGFloat(titlesAndIcons.count))
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if tapOutsideRecognizer == nil {
            tapOutsideRecognizer = UITapGestureRecognizer(target: self, action: #selector(PopOverMenuViewController.handleTapBehind(_:)))
            tapOutsideRecognizer.numberOfTapsRequired = 1
            tapOutsideRecognizer.cancelsTouchesInView = false
            tapOutsideRecognizer.delegate = self
            view.window?.addGestureRecognizer(tapOutsideRecognizer)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return titlesAndIcons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let (title, icon) = titlesAndIcons[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "PopOverMenuTableViewCell") as! PopOverMenuTableViewCell

        cell.iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
        cell.titleLabel.text = title

        cell.iconImageView.tintColor = tintColor ?? UIColor.black
        cell.titleLabel.textColor = tintColor ?? UIColor.black

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return rowHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        delegate?.popOverMenuViewController?(self, didSelectMenuItemAtIndex: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func handleTapBehind(_ sender: UITapGestureRecognizer) {

        if sender.state == UIGestureRecognizerState.ended {
            let location: CGPoint = sender.location(in: nil)

            if !view.point(inside: view.convert(location, from: view.window), with: nil) {
                view.window?.removeGestureRecognizer(sender)
                dismiss(animated: true, completion: nil)
            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
