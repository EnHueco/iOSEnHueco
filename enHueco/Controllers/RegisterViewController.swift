//
//  RegisterViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 12/6/14.
//  Copyright (c) 2014 Diego Gómez. All rights reserved.
//

import UIKit

class RegisterViewController : UIViewController, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBOutlet weak var mailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var passwordConfirm: UITextField!

    
    
    @IBAction func register(sender: AnyObject) {
/*
        let params = [
            "email":"\(mailInput.text)@uniandes.edu.co",
            "password":passwordInput.text,
            "password_confirmation":passwordConfirm.text
        ]
        
        let jsonData = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted, error: nil)!
        
        var request = NSMutableURLRequest(URL: NSURL(string: "http://\(GlobalConstants.DOMAIN):\(GlobalConstants.PORT)/api/user/register")!)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonData
        
        
        NSURLConnection(request: request, delegate: self)
*/
        
    }
    


    func connection(connection: NSURLConnection, didReceiveData dataReceived: NSData) {
        println("RESPONSE RECEIVED")
        let response = NSJSONSerialization.JSONObjectWithData(dataReceived, options: NSJSONReadingOptions.MutableContainers, error: nil)!
        println(response)
        
        if response["token"] != nil
        {
            // No hay errores
            println("No hay errores")
            let editScheduleViewController = self.storyboard!.instantiateViewControllerWithIdentifier("editSchedule")
            self.presentViewController(editScheduleViewController as EditScheduleViewController, animated: true, completion: nil)
        }
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print("ERROR")
        print(error)
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
}
