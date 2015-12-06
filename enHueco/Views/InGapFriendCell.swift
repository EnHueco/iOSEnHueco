//
//  InGapFriendCell.swift
//  enHueco
//
//  Created by Diego on 9/6/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class InGapFriendCell: SWTableViewCell
{
    @IBOutlet weak var friendImageImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var gapStartOrEndHourIconImageView: UIImageView!
    @IBOutlet weak var gapStartOrEndHourLabel: UILabel!
    @IBOutlet weak var gapNameAndLocationLabel: UILabel!
    
    var friendUsername : String? = nil
    
}
