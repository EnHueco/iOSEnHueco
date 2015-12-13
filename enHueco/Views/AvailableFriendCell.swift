//
//  AvailableFriendCell.swift
//  enHueco
//
//  Created by Diego on 9/6/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class AvailableFriendCell: SWTableViewCell
{
    @IBOutlet weak var friendImageImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var freeTimeStartOrEndHourIconImageView: UIImageView!
    @IBOutlet weak var freeTimeStartOrEndHourLabel: UILabel!
    @IBOutlet weak var freeNameAndLocationLabel: UILabel!
    
    var friendUsername : String? = nil
    
}
