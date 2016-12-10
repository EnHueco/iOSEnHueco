//
//  FriendRequestCell.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 10/7/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

@objc protocol IncomingFriendRequestCellDelegate: class {
    @objc optional func didPressDiscardButtonInIncomingFriendRequestCell(_ cell: IncomingFriendRequestCell)

    @objc optional func didPressAcceptButtonInIncomingFriendRequestCell(_ cell: IncomingFriendRequestCell)
}

class IncomingFriendRequestCell: UITableViewCell {
    weak var delegate: IncomingFriendRequestCellDelegate?

    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var friendImageImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func discardButtonPressed(_ sender: Any) {

        if let delegate = delegate {
            delegate.didPressDiscardButtonInIncomingFriendRequestCell?(self)
        }
    }

    @IBAction func acceptButtonPressed(_ sender: AnyObject) {

        if let delegate = delegate {
            delegate.didPressAcceptButtonInIncomingFriendRequestCell?(self)
        }
    }
}
