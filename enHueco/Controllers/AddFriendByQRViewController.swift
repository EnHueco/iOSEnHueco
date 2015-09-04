//
//  AddFriendByQRViewController.swift
//  enHueco
//
//  Created by Diego on 8/31/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class AddFriendByQRViewController: UIViewController
{
    let writer = ZXMultiFormatWriter.writer() as! ZXMultiFormatWriter
    var matrix: ZXBitMatrix!

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        matrix = try! writer.encode(system.appUser.stringEncodedUserRepresentation(), format: kBarcodeFormatQRCode, width: 200, height: 200)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
