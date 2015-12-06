//
//  FriendsTableViewCell.swift
//  enHueco
//
//  Created by Diego Gómez on 1/23/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell
{
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var gapStartOrEndHourLabel: UILabel!
    @IBOutlet weak var gapStartOrEndHourIconImageView: UIImageView!
    @IBOutlet weak var eventNameOrLocationLabel: UILabel!
    @IBOutlet weak var friendImageImageView: UIImageView!
    @IBOutlet weak var gapStartEndHourIconWidthConstraint: NSLayoutConstraint!
    
    func hideGapStartEndHourIcon()
    {
        gapStartEndHourIconWidthConstraint.constant = 0
    }
    
    func showGapStartEndHourIcon()
    {
        gapStartEndHourIconWidthConstraint.constant = 15
    }
    
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
}
