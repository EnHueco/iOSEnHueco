//
//  AppController.swift
//  enHueco
//
//  Created by Diego Gómez on 2/3/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation

class AppController
{
    let api : APIConnector?
    var delegate : AppControllerDelegate?
    
    init(delegate:AppControllerDelegate)
    {
        self.api = APIConnector()
        self.delegate = delegate
    }
    
    func authenticateUser(login:String, password:String)
    {
        let loginSuccessBlock  = {
            (login:String, token:String)->() in
            AppUser.sharedInstance.login = login
            AppUser.sharedInstance.token = token
            self.delegate?.AppControllerValidResponseReceived()

            return
        }
        
        let loginFailureBlock = {
            (errorResponse:NSString)->() in
            print(errorResponse)
            //self.delegate?.AppControllerValidResponseReceived(errorResponse)
//            self.delegate?.AppControllerInvalidResponseReceived(errorResponse)
        }
        
        self.api?.sendLoginRequest(login, password: password, onLoginSuccessBlock: loginSuccessBlock, onLoginFailureBlock: loginFailureBlock)
    }
    
    func getLocalAndUpdateRemoteAppUser()->AppUser
    {
        let getUserSuccessBlock  = {
            (user:AppUser)->() in
            
            AppUser.updateUser(user)
            self.sendResponseToDelegate()
        }
        
        let getUserFailureBlock = {
            (errorResponse:NSString)->() in
            print(errorResponse)
            
        }
        
        self.api?.getAppUserRequest(AppUser.sharedInstance.login!, token: AppUser.sharedInstance.token!, onGetUserSuccessBlock: getUserSuccessBlock, onGetUserFailureBlock: getUserFailureBlock)
        return getLocalAppUser()
    }
    
    func getLocalAppUser()->AppUser
    {
        let user = AppUser.sharedInstance
        return user
    }
    
    private func sendResponseToDelegate()
    {
        dispatch_async(dispatch_get_main_queue()){
            
            self.delegate!.AppControllerValidResponseReceived()
        }
    }
}

protocol AppControllerDelegate
{
    func AppControllerValidResponseReceived()
    func AppControllerInvalidResponseReceived(errorResponse:NSString)
}