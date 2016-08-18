//
//  CommonFreeTimePeriodsSelectedFriendsCollectionViewCell.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/10/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class CommonFreeTimePeriodsSelectedFriendsCollectionViewCell: UICollectionViewCell
{    
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var deleteButtonWidthConstraint: NSLayoutConstraint!
    
    func setDeleteButtonHidden(hidden: Bool)
    {
        deleteButtonWidthConstraint.constant = hidden ? 0 : 20
        layoutIfNeeded()
    }
}
