//
//  Constant.swift
//  FeelingClient
//
//  Created by Vincent on 16/7/8.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import Foundation

struct Constant {
    
    static var RIMStatus = 0
    static var messagecount = 0
    static var Devicetoken = ""
    static var messagecountAPNS = 0
    static let SECERT: String = "FEELING_ME007"
    static let JWTDEMOTOKEN: String = "JWTDEMOTOKEN"
    static let FEELINGUSERNAME: String = "FEELINGUSERNAME"
    static let FEELINGPSWORD: String = "FEELINGPSWORD"
    static let JWTDEMOTEMP: String = "JWTDEMOTEMP"
    static let JWTSIGN: String = "JWTSIGN"
    static let JWTSIGNFILE: String = "JWTSIGNFILE"
    static let AUTHORIZATION_STR: String = "Authorization"
    static let IMTOKENTEMP: String = "IMTOKENTEMP"
    static let USERID: String = "FEELING_USERID"
    static let USERINFO: String = "FEELING_USERINFO"
    static let USERAVOTOR: String = "FEELING_USERAVOTOR"
    static let Database = NSUserDefaults.standardUserDefaults()
    static let Notifi = NSNotificationCenter.defaultCenter()
    static let RongCloudUnreadMessageNotifi = "hasUnreadMessagesNotifi"
    static let APNSUnreadMessageNotifi = "hasUnreadMessagesNotifiAPNS"
}
