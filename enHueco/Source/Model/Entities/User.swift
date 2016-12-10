//
//  Friend.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation
import Genome

enum Gender: String, NodeConvertible {
    case Male = "Male"
    case Female = "Female"
}

class User: MappableObject, Equatable {

    struct JSONKeys {
        fileprivate init() {}

        static let id = "id"
        static let institution = "institution"
        static let firstNames = "first_names"
        static let lastNames = "last_names"
        static let image = "image"
        static let imageThumbnail = "image_thumbnail"
        static let phoneNumber = "phone_number"
        static let gender = "gender"
    }

    let id: String
    let institution: String?
    let firstNames: String
    let lastNames: String
    let image: URL?
    let imageThumbnail: URL?
    let phoneNumber: String?
    let gender: Gender
    
    var name: String { return "\(firstNames) \(lastNames)" }
    
    init(id: String, institution: String?, firstNames: String, lastNames: String, image: URL? = nil, imageThumbnail: URL? = nil, phoneNumber: String? = nil, gender: Gender) {
        
        self.id = id
        self.institution = institution
        self.firstNames = firstNames
        self.lastNames = lastNames
        self.image = image
        self.imageThumbnail = imageThumbnail
        self.phoneNumber = phoneNumber
        self.gender = gender
    }
    
    required init(map: Map) throws {
        
        id = try map.extract(JSONKeys.id)
        institution = try? map.extract(JSONKeys.institution)
        
        let firstNames = try map.extract(JSONKeys.firstNames) as [String]
        let lastNames = try map.extract(JSONKeys.lastNames) as [String]
        
        self.firstNames = firstNames.joined(separator: " ")
        self.lastNames = lastNames.joined(separator: " ")
        
        image = try? map.extract(JSONKeys.image)
        imageThumbnail = try? map.extract(JSONKeys.imageThumbnail)
        phoneNumber = try? map.extract(JSONKeys.phoneNumber)
        gender = try map.extract(JSONKeys.gender)
    }
    
//    static func newInstance(_ json: Json, context: Context) throws -> Self {
//        let map = Map(json: json, context: context)
//        let new = try self.init(map: map)
//        try new.sequence(map)
//        return new
//    }
    
    func sequence(_ map: Map) throws {
        
        try id ~> map[JSONKeys.id]
        try institution ~> map[JSONKeys.institution]
        try institution ~> map[JSONKeys.institution]
        try firstNames.components(separatedBy: " ") ~> map[JSONKeys.firstNames]
        try lastNames.components(separatedBy: " ") ~> map[JSONKeys.lastNames]
        try image ~> map[JSONKeys.image]
        try imageThumbnail ~> map[JSONKeys.imageThumbnail]
        try phoneNumber ~> map[JSONKeys.phoneNumber]
        try gender ~> map[JSONKeys.gender]
    }
    
    /*
    var outgoingFriendRequests = [User]()
    var incomingFriendRequests = [User]()

    override init(username: String, firstNames: String, lastNames: String, phoneNumber: String!, imageURL: NSURL?, imageThumbnailURL: NSURL?, ID: String, lastUpdatedOn: NSDate) {
        super.init(username: username, firstNames: firstNames, lastNames: lastNames, phoneNumber: phoneNumber, imageURL: imageURL, imageThumbnailURL: imageThumbnailURL, ID: ID, lastUpdatedOn: lastUpdatedOn)
    }

    override init(JSONDictionary: [String:Any]) {
        super.init(JSONDictionary: JSONDictionary)
    }

    // MARK: NSCoding

    required init?(coder decoder: NSCoder) {
        guard
        let friends = decoder.decodeObjectForKey("friends") as? [String:User],
        let incomingFriendRequests = decoder.decodeObjectForKey("incomingFriendRequests") as? [User],
        let outgoingFriendRequests = decoder.decodeObjectForKey("outgoingFriendRequests") as? [User]
        else {
            return nil
        }

        self.friends = friends
        self.incomingFriendRequests = incomingFriendRequests
        self.outgoingFriendRequests = outgoingFriendRequests

        super.init(coder: decoder)
    }

    override func encodeWithCoder(coder: NSCoder) {

        super.encodeWithCoder(coder)

        coder.encodeObject(friends, forKey: "friends")
        coder.encodeObject(incomingFriendRequests, forKey: "incomingFriendRequests")
        coder.encodeObject(outgoingFriendRequests, forKey: "outgoingFriendRequests")
    }

    /// When currentBSSID is set, refreshes the isNearby property for all friends.
    override func refreshIsNearby() {

        for friend in friends.values {
            friend.refreshIsNearby()
        }
    }

    override func updateUserWithJSONDictionary(JSONDictionary: [String:Any]) {

        super.updateUserWithJSONDictionary(JSONDictionary)

        PrivacyManager.sharedManager.changeUserDefaultsValueForPrivacySetting(.ShowEventLocations, toNewValue: JSONDictionary[PrivacySetting.ShowEventLocations.rawValue] as! Bool)
        PrivacyManager.sharedManager.changeUserDefaultsValueForPrivacySetting(.ShowEventNames, toNewValue: JSONDictionary[PrivacySetting.ShowEventNames.rawValue] as! Bool)
    }

    var schedule = Schedule()

    /// (For efficiency) True if the user is near the App User at the current time, given the currentBSSID values.
    private(set) var isNearby = false

    var currentBSSID: String? {
        didSet {
            if currentBSSID != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    NSTimer.scheduledTimerWithTimeInterval(self.currentBSSIDTimeToLive, target: self, selector: #selector(User.currentBSSIDTimeToLiveReached(_:)), userInfo: nil, repeats: false)
                }
            }

            refreshIsNearby()
        }
    }

    /// Time until currentBSSID is set back to nil
    let currentBSSIDTimeToLive: NSTimeInterval = 60 * 5
    //5 minutes

    ///Last time we notified the app user that this user was nearby
    var lastNotifiedNearbyStatusDate: NSDate?

    /** The ending date of the user invisibility.
     The user is visible if this is either nil or a date in the past.
    */
    private var inivisibilityEndDate: NSDate?

    ///User visibility state
    var isInvisible: Bool {
        return inivisibilityEndDate != nil && inivisibilityEndDate!.timeIntervalSinceNow > 0
    }

    init(username: String, firstNames: String, lastNames: String, phoneNumber: String!, imageURL: NSURL?, imageThumbnailURL: NSURL?, ID: String, lastUpdatedOn: NSDate) {
        self.username = username
        self.firstNames = firstNames
        self.lastNames = lastNames
        self.phoneNumber = phoneNumber
        self.imageURL = imageURL
        self.imageThumbnailURL = imageThumbnailURL

        schedule = Schedule()

        super.init(ID: ID, lastUpdatedOn: lastUpdatedOn)
    }

    init(JSONDictionary: [String:Any]) {
        self.username = JSONDictionary["login"] as! String
        self.firstNames = JSONDictionary["firstNames"] as! String
        self.lastNames = JSONDictionary["lastNames"] as! String
        self.imageURL = ((JSONDictionary["imageURL"] == nil || JSONDictionary["imageURL"] is NSNull) ? nil : NSURL(string: (EHURLS.Base + (JSONDictionary["imageURL"]! as! String)).replace("https", withString: "http")))
        self.imageThumbnailURL = ((JSONDictionary["image_thumbnail"] == nil || JSONDictionary["image_thumbnail"] is NSNull) ? nil : NSURL(string: (EHURLS.Base + (JSONDictionary["image_thumbnail"]! as! String)).replace("https", withString: "http")))
        self.phoneNumber = JSONDictionary["phoneNumber"] as? String

        if let JSONEvents = JSONDictionary["gap_set"] as? [[String:Any]] {
            schedule = Schedule(JSONEvents: JSONEvents)
        }

        let lastUpdatedOn = NSDate(serverFormattedString: JSONDictionary["updated_on"] as! String)!

        if let instantEvent = JSONDictionary["immediate_event"] as? [String:Any],
        let endDate = NSDate(serverFormattedString: instantEvent["valid_until"] as! String),
        let type = instantEvent["type"] as? String
        where endDate.timeIntervalSinceNow > 0 {
            if type == "INVISIBILITY" {
                inivisibilityEndDate = endDate
            } else if type == "EVENT" {
                schedule.instantFreeTimePeriod = Event(instantFreeTimeJSONDictionary: instantEvent)
            }
        }

        super.init(ID: username, lastUpdatedOn: lastUpdatedOn)
    }

    func updateUserWithJSONDictionary(JSONDictionary: [String:Any]) {

        let dummyUser = User(JSONDictionary: JSONDictionary)

        firstNames = dummyUser.firstNames
        lastNames = dummyUser.lastNames
        phoneNumber = dummyUser.phoneNumber
        imageURL = dummyUser.imageURL
        imageThumbnailURL = dummyUser.imageThumbnailURL
        inivisibilityEndDate = dummyUser.inivisibilityEndDate
        schedule = dummyUser.schedule
    }

    /** The ending date of the user invisibility.
     The user is visible if this is either nil or a date in the past.
     */
    func setInivisibilityEndDate(date: NSDate?) {

        inivisibilityEndDate = date
    }

    func addEvents(JSONDictionary: [String:Any]) {

        let eventSet = JSONDictionary["gap_set"] as! [[String:Any]]

        for eventJSON in eventSet {
            let event = Event(JSONDictionary: eventJSON)
            schedule.weekDays[event.localWeekDay()].addEvent(event)
        }
    }

    func currentBSSIDTimeToLiveReached(timer: NSTimer) {

        currentBSSID = nil
    }

    /// When current BSSID is set, checks if user is near the App User and updates the value of the isNearby property.
    func refreshIsNearby() {

        if let appUserBSSID = enHueco.appUser.currentBSSID, currentBSSID = currentBSSID {
            isNearby = ProximityUpdatesManager.sharedManager.wifiAccessPointWithBSSID(appUserBSSID, isNearAccessPointWithBSSID: currentBSSID)
        } else {
            isNearby = false
        }
    }

    // MARK: NSCoding

    required init?(coder decoder: NSCoder) {
        guard
        let username = decoder.decodeObjectForKey("username") as? String,
        let firstNames = decoder.decodeObjectForKey("firstNames") as? String,
        let lastNames = decoder.decodeObjectForKey("lastNames") as? String,
        let schedule = decoder.decodeObjectForKey("schedule") as? Schedule
        else {
            return nil
        }

        self.username = username

        self.firstNames = firstNames
        self.lastNames = lastNames
        self.phoneNumber = decoder.decodeObjectForKey("phoneNumber") as? String
        self.imageURL = decoder.decodeObjectForKey("imageURL") as? NSURL
        self.imageThumbnailURL = decoder.decodeObjectForKey("imageThumbnailURL") as? NSURL
        self.schedule = schedule
        self.lastNotifiedNearbyStatusDate = decoder.decodeObjectForKey("lastNotifiedNearbyStatusDate") as? NSDate

        super.init(coder: decoder)
    }

    override func encodeWithCoder(coder: NSCoder) {

        coder.encodeObject(username, forKey: "username")
        coder.encodeObject(firstNames, forKey: "firstNames")
        coder.encodeObject(lastNames, forKey: "lastNames")
        coder.encodeObject(phoneNumber, forKey: "phoneNumber")
        coder.encodeObject(imageURL, forKey: "imageURL")
        coder.encodeObject(imageThumbnailURL, forKey: "imageThumbnailURL")
        coder.encodeObject(schedule, forKey: "schedule")
        coder.encodeObject(lastNotifiedNearbyStatusDate, forKey: "lastNotifiedNearbyStatusDate")

        super.encodeWithCoder(coder)
    }
 */
}

func == (lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}

extension String {
    func replace(_ target: String, withString: String) -> String {

        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

