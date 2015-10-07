//
//  APIurls.swift
//  enHueco
//
//  Created by Diego Gómez on 2/2/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation

enum EHURLS: String
{
    case Base = "http://enhueco.uniandes.edu.co"
    case AuthSegment = "/auth/"
    case FriendSegment = "/friends/"
    case OutgoingFriendRequestsSegment = "/requests/sent/", IncomingFriendRequestsSegment = "/requests/received/"
}

enum EHParameters: String
{
    case UserID = "X-USER-ID"
    case Token = "X-USER-TOKEN"
}

/*public class APIURLS
{
    
    // BASIC Settings
    let TESTDOMAIN : String = "http://enhueco.virtual.uniandes.edu.co"
    let PRODUCTION_DOMAIN: String = "enhueco.uniandes.edu.co"
    let PORT = "80"
    
    let DOMAIN : String
    
    // Funcitonal URIs
    let AUTHENTICATIONURI : String = "/auth/"
    let GETAPPUSERURI : String = "/me/"

    //Functional URLs
    let AUTHENTICATIONURL : NSURL
    let GETAPPUSERURL : NSURL
    
    init(production: Bool)
    {
        if(production)
        {
            DOMAIN = self.PRODUCTION_DOMAIN
        }
        else
        {
            DOMAIN = self.TESTDOMAIN
        }
        
        // Define URLs
        let baseURL = DOMAIN+":"+PORT+"/api"
        self.AUTHENTICATIONURL = NSURL(string: baseURL + AUTHENTICATIONURI)!
        self.GETAPPUSERURL = NSURL(string: baseURL + GETAPPUSERURI)!
    }
}*/
