//
//  JWTTools.swift
//  Temp
//
//  Created by vincent on 8/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation

import JWT

struct JWTTools {
    
    let SECERT: String = "FEELING_ME007"
    let JWTDEMOTOKEN: String = "JWTDEMOTOKEN"
    let FEELINGUSERNAME: String = "FEELINGUSERNAME"
    let FEELINGPSWORD: String = "FEELINGPSWORD"
    let JWTDEMOTEMP: String = "JWTDEMOTEMP"
    let JWTSIGN: String = "JWTSIGN"
    let JWTSIGNFILE: String = "JWTSIGNFILE"
    let AUTHORIZATION_STR: String = "Authorization"
    let IMTOKENTEMP: String = "IMTOKENTEMP"
    let USERID: String = "FEELING_USERID"
    let USERINFO: String = "FEELING_USERINFO"
    let USERAVOTOR: String = "FEELING_USERAVOTOR"
    
    var appUsername: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(FEELINGUSERNAME) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: FEELINGUSERNAME)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var appPwd: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(FEELINGPSWORD) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: FEELINGPSWORD)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
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
    var sign_file: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(JWTSIGNFILE) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: JWTSIGNFILE)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var jwtTemp: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(JWTDEMOTEMP) as? String {
//                NSLog("\(returnValue)")
                
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
    
    var imToken: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(IMTOKENTEMP) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: IMTOKENTEMP)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    
    
    var userId: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(USERID) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: USERID)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var userName: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(USERINFO) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: USERINFO)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var userAvator: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(USERAVOTOR) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: USERAVOTOR)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    mutating func getHeader(tokenNew: String, myDictionary: Dictionary<String, String> ) -> [String : String] {
        if jwtTemp.isEmpty || !myDictionary.isEmpty {//重复使用上次计算结果
            let jwt = JWT.encode(.HS256(SECERT)) { builder in
                for (key, value) in myDictionary {
                    builder[key] = value
                }
                builder["token"] = tokenNew
            }
            if !myDictionary.isEmpty && tokenNew == self.token {//不填充新数据
                jwtTemp = jwt
            }
            return [ AUTHORIZATION_STR : jwt ]
        }
        else {
            return [ AUTHORIZATION_STR : jwtTemp ]
        }
    }
}


func getSex(name:String) -> String {
    if name=="MALE" {
        return "男"
    }
    if name=="FEMALE"{
        return "女"
    }
    else {
        return "无"
    }
}


func loginRIM(){
    if jwt.imToken.length != 0 {
        RCIM.sharedRCIM().connectWithToken(jwt.imToken,
                                           success: { (userId) -> Void in
                                            //设置当前登陆用户的信息
                                            RCIM.sharedRCIM().currentUserInfo = RCUserInfo.init(userId: userId, name: jwt.userName,portrait: jwt.userAvator)
            }, error: { (status) -> Void in
                
            }, tokenIncorrect: {
                print("token错误")
        })
    }
}
