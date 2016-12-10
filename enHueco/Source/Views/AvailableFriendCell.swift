//
//  AvailableFriendCell.swift
//  enHueco
//
//  Created by Diego on 9/6/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import SWTableViewCell

class AvailableFriendCell: SWTableViewCell {
    @IBOutlet weak var friendImageImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var freeTimeStartOrEndHourIconImageView: UIImageView!
    @IBOutlet weak var freeTimeStartOrEndHourLabel: UILabel!
    @IBOutlet weak var freeNameAndLocationLabel: UILabel!
    @IBOutlet weak var instantFreeTimeIcon: UIImageView!

    @IBOutlet weak var instantFreeTimeIconWidthConstraint: NSLayoutConstraint!

    var friendUsername: String? = nil

    func setInstantFreeTimeIconVisibility(_ visible: Bool) {

        instantFreeTimeIconWidthConstraint.constant = visible ? 25 : 0
    }
}
