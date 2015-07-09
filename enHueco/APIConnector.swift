//
//  APIConnector.swift
//  enHueco
//
//  Created by Diego Gómez on 2/2/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation

class APIConnector {
    
    let apiurls : APIurls = APIurls(production: false)
    
//    let user : User?

    
    func sendLoginRequest(login:String, password:String, onLoginSuccessBlock: (login:String, token:String) -> (), onLoginFailureBlock:(NSString) -> ()) {
        
        var url = apiurls.AUTHENTICATIONURL
        var dictionary: NSDictionary = ["login": login, "password": password]
        
        var httpRRM = HTTPRequestResponseManager()
        
        var successfulLogin = {
            (dict:NSDictionary)->() in
            var login = dict["owner"] as String
            var token = dict["value"] as String
            onLoginSuccessBlock(login:login, token:token)
        }
        
        var failureLogin = {
            (errorResponse:NSString)->() in
            onLoginFailureBlock(errorResponse)
        }
        
        var successfulRequestBlock = {
            (data:NSData)->() in
            self.onSuccessfulRequest(data, successBlock: successfulLogin, failureBlock: failureLogin)
        }
        
        httpRRM.sendRequest(url, method: HTTPRequestResponseManager.POST , dictionary: dictionary, successfulRequestBlock: successfulRequestBlock, failureRequestBlock:self.printFailureRequest)
    }
    
    
    func getAppUserRequest(login:NSString, token:NSString, onGetUserSuccessBlock:(AppUser)->(),onGetUserFailureBlock:NSString->()){
        var url = apiurls.GETAPPUSERURL
        var dictionary = ["login":login, "token":token]
        var httpRRM = HTTPRequestResponseManager()
        
        var successfulGetAppUser = {
            (dict:NSDictionary) -> () in
            var user = AppUser.dictionaryToAppUser(dict)
            onGetUserSuccessBlock(user!)
        }
        var failureGetAppUser = {
            (errorResponse:NSString)->() in
            onGetUserFailureBlock(errorResponse)
        }
        var successfulRequestBlock = {
            (data:NSData)->() in
            self.onSuccessfulRequest(data, successBlock: successfulGetAppUser, failureBlock: failureGetAppUser)
        }

        httpRRM.sendRequest(url, method: HTTPRequestResponseManager.POST, dictionary: dictionary, successfulRequestBlock: successfulRequestBlock, failureRequestBlock: self.printFailureRequest)

    }    
    
    private func onSuccessfulRequest(data: NSData, successBlock:(NSDictionary) -> (), failureBlock:(NSString) -> () ){

        var response = NSString(data: data, encoding: NSUTF8StringEncoding)

        if(response!.containsString("ERROR"))
        {
            failureBlock(response!)
        }
        else
        {
            var jsonSerializationError : NSError?
            var jsonData : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: &jsonSerializationError) as NSDictionary
            
            successBlock(jsonData)
        }
    }
    private func printFailureRequest(error:NSError)
    {
        print(error.description)
    }
}
