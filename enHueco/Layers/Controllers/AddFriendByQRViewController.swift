//
//  AddFriendByQRViewController.swift
//  enHueco
//
//  Created by Diego on 8/31/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReaderViewController
import QRCode

class AddFriendByQRViewController: UIViewController, QRCodeReaderDelegate
{
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var appUserQRImageView: UIImageView!
    @IBOutlet weak var scanQRButton: UIButton!
    
    lazy var reader = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
                
        let code = QRCode(enHueco.appUser.stringEncodedUserRepresentation())
        appUserQRImageView.image = code?.image
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        scanQRButton.clipsToBounds = true
        scanQRButton.layer.cornerRadius = scanQRButton.frame.height/2
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func scanQRButtonPressed(sender: AnyObject)
    {
        reader.delegate = self
        
        reader.modalPresentationStyle = .FormSheet
        presentViewController(reader, animated: true, completion: nil)
    }
    
    func reader(reader: QRCodeReaderViewController, didScanResult result: String)
    {
        dismissViewControllerAnimated(true, completion: nil)
        
        try! FriendsManager.addFriendFromStringEncodedFriendRepresentation(result)
        
        navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func readerDidCancel(reader: QRCodeReaderViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
