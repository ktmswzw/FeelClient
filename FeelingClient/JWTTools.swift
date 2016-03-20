//
//  JWTTools.swift
//  Temp
//
//  Created by vincent on 8/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation

import JWT

class JWTTools {
    
    let SECERT: String = "FEELING_ME007";
    let JWTDEMOTOKEN: String = "JWTDEMOTOKEN";
    let JWTDEMOTEMP: String = "JWTDEMOTEMP";
    let JWTSIGN: String = "JWTSIGN";
    let AUTHORIZATION_STR: String = "Authorization";
    
    var token: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(JWTDEMOTOKEN) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: JWTDEMOTOKEN)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var sign: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(JWTSIGN) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: JWTSIGN)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var jwtTemp: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(JWTDEMOTEMP) as? String {
                NSLog("\(returnValue)")
                
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: JWTDEMOTEMP)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func getHeader(tokenNew: String, myDictionary: Dictionary<String, String> ) -> [String : String] {
        if jwtTemp.isEmpty || !myDictionary.isEmpty {//重复使用上次计算结果
            let jwt = JWT.encode(.HS256(SECERT)) { builder in
                for (key, value) in myDictionary {
                    builder[key] = value
                }
                builder["token"] = tokenNew
            }
            NSLog("\(jwt)")
            if !myDictionary.isEmpty && tokenNew == self.token {//不填充新数据
                jwtTemp = jwt
            }
            return [ AUTHORIZATION_STR : jwt ]
        }
        else {
            NSLog("\(jwtTemp)")
            return [ AUTHORIZATION_STR : jwtTemp ]
        }
    }
}