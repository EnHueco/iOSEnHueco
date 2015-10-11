//
//  AddFriendByQRViewController.swift
//  enHueco
//
//  Created by Diego on 8/31/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit
import AVFoundation

class AddFriendByQRViewController: UIViewController, QRCodeReaderDelegate
{
    @IBOutlet weak var appUserQRImageView: UIImageView!
    @IBOutlet weak var scanQRButton: UIButton!
    
    lazy var reader = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//        let code = QRCode(system.appUser.stringEncodedUserRepresentation())
//        appUserQRImageView.image = code?.image
        
        scanQRButton.clipsToBounds = true
        scanQRButton.layer.cornerRadius = 4
    }
    
    override func viewWillAppear(animated: Bool)
    {
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
        
//        try! system.appUser.addFriendFromStringEncodedFriendRepresentation(result)
        
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
