//
//  PopOverMenuTableViewCell.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 12/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class PopOverMenuTableViewCell: UITableViewCell
{
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

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
