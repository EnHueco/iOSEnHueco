//
//  APIConnector.swift
//  enHueco
//
//  Created by Diego Gómez on 2/2/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation

class APIConnector
{
    let apiurls : APIurls = APIurls(production: false)
    
//    let user : User?

    func sendLoginRequest(login:String, password:String, onLoginSuccessBlock: (login:String, token:String) -> (), onLoginFailureBlock:(NSString) -> ())
    {
        let url = apiurls.AUTHENTICATIONURL
        let dictionary: NSDictionary = ["login": login, "password": password]
        
        let httpRRM = HTTPRequestResponseManager()
        
        let successfulLogin =
        {
            (dict:NSDictionary)->() in
            let login = dict["owner"] as! String
            let token = dict["value"] as! String
            onLoginSuccessBlock(login:login, token:token)
        }
        
        let failureLogin = {
            (errorResponse:NSString)->() in
            onLoginFailureBlock(errorResponse)
        }
        
        let successfulRequestBlock = {
            (data:NSData)->() in
            self.onSuccessfulRequest(data, successBlock: successfulLogin, failureBlock: failureLogin)
        }
        
        httpRRM.sendRequest(url, method: HTTPRequestResponseManager.POST , dictionary: dictionary, successfulRequestBlock: successfulRequestBlock, failureRequestBlock:self.printFailureRequest)
    }
    
    
    func getAppUserRequest(login:NSString, token:NSString, onGetUserSuccessBlock:(AppUser)->(),onGetUserFailureBlock:NSString->())
    {
        let url = apiurls.GETAPPUSERURL
        let dictionary = ["login":login, "token":token]
        let httpRRM = HTTPRequestResponseManager()
        
        let successfulGetAppUser = {
            (dict:NSDictionary) -> () in
            let user = AppUser.dictionaryToAppUser(dict)
            onGetUserSuccessBlock(user)
        }
        
        let failureGetAppUser = {
            (errorResponse:NSString)->() in
            onGetUserFailureBlock(errorResponse)
        }
        
        let successfulRequestBlock = {
            (data:NSData)->() in
            self.onSuccessfulRequest(data, successBlock: successfulGetAppUser, failureBlock: failureGetAppUser)
        }

        httpRRM.sendRequest(url, method: HTTPRequestResponseManager.POST, dictionary: dictionary, successfulRequestBlock: successfulRequestBlock, failureRequestBlock: self.printFailureRequest)
    }    
    
    private func onSuccessfulRequest(data: NSData, successBlock:(NSDictionary) -> (), failureBlock:(NSString) -> () )
    {
        let response = NSString(data: data, encoding: NSUTF8StringEncoding)

        if(response!.containsString("ERROR"))
        {
            failureBlock(response!)
        }
        else
        {
            do
            {
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                successBlock(jsonData)
            }
            catch
            {
                
            }
            
        }
    }
    private func printFailureRequest(error:NSError)
    {
        print(error.description)
    }
}
