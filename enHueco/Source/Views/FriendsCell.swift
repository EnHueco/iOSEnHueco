//
//  FriendsTableViewCell.swift
//  enHueco
//
//  Created by Diego Gómez on 1/23/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell {
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var freeTimeStartOrEndHourLabel: UILabel!
    @IBOutlet weak var freeTimeStartOrEndHourIconImageView: UIImageView!
    @IBOutlet weak var eventNameOrLocationLabel: UILabel!
    @IBOutlet weak var friendImageImageView: UIImageView!
    @IBOutlet weak var freeTimeStartEndHourIconWidthConstraint: NSLayoutConstraint!

    func hideFreeTimeStartEndHourIcon() {

        freeTimeStartEndHourIconWidthConstraint.constant = 0
    }

    func showFreeTimeStartEndHourIcon() {

        freeTimeStartEndHourIconWidthConstraint.constant = 15
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
