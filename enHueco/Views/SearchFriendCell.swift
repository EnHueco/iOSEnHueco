//
//  SearchFriendCell.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/7/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

@objc protocol SearchFriendCellDelegate: class
{
    optional func didPressAddButtonInSearchFriendCell(cell:SearchFriendCell)
}

class SearchFriendCell: UITableViewCell
{
    weak var delegate: SearchFriendCellDelegate?

    @IBOutlet weak var friendNameLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addButtonPressed(sender: AnyObject)
    {
        if let delegate = delegate
        {
            delegate.didPressAddButtonInSearchFriendCell?(self)
        }
    }
}
