//
//  APIurls.swift
//  enHueco
//
//  Created by Diego Gómez on 2/2/15.
//  Copyright (c) 2015 Diego Gómez. All rights reserved.
//

import Foundation

/// Error domain prefix for NSErrors 
let ehBaseErrorDomain = "com.enhueco"

/// URLS
class EHURLS
{
    static let Domain = "enhueco.uniandes.edu.co"
    static let Base = "https://enhueco.uniandes.edu.co/api"
    static let MeSegment = "/me/"
    static let MeImageSegment = "/me/image/"
    static let AuthSegment = "/auth/"
    static let FriendsSegment = "/friends/"
    static let OutgoingFriendRequestsSegment = "/requests/sent/", IncomingFriendRequestsSegment = "/requests/received/"
    static let UsersSegment = "/users/"
    static let EventsSegment = "/gaps/"
    static let LocationReportSegment = "/me/location/friends/"
    static let ImmediateEventsSegment = "/events/immediate/"
}

/// Default parameters
class EHParameters
{
    static let UserID = "X-USER-ID"
    static let Token = "X-USER-TOKEN"
}