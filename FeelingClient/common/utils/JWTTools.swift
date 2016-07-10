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
       
    var appUsername: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(Constant.FEELINGUSERNAME) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Constant.FEELINGUSERNAME)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var appPwd: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(Constant.FEELINGPSWORD) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Constant.FEELINGPSWORD)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var token: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(Constant.JWTDEMOTOKEN) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Constant.JWTDEMOTOKEN)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var sign: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(Constant.JWTSIGN) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Constant.JWTSIGN)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var sign_file: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(Constant.JWTSIGNFILE) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Constant.JWTSIGNFILE)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var jwtTemp: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(Constant.JWTDEMOTEMP) as? String {
//                NSLog("\(returnValue)")
                
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Constant.JWTDEMOTEMP)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var imToken: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(Constant.IMTOKENTEMP) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Constant.IMTOKENTEMP)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    
    
    var userId: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(Constant.USERID) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Constant.USERID)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var userName: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(Constant.USERINFO) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Constant.USERINFO)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var userAvator: String {
        get {
            if let returnValue = NSUserDefaults.standardUserDefaults().objectForKey(Constant.USERAVOTOR) as? String {
                return returnValue
            } else {
                return "" //Default value
            }
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Constant.USERAVOTOR)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    mutating func getHeader(tokenNew: String, myDictionary: Dictionary<String, String> ) -> [String : String] {
        if jwtTemp.isEmpty || !myDictionary.isEmpty {//重复使用上次计算结果
            let jwt = JWT.encode(.HS256(Constant.SECERT)) { builder in
                for (key, value) in myDictionary {
                    builder[key] = value
                }
                builder["token"] = tokenNew
            }
            if !myDictionary.isEmpty && tokenNew == self.token {//不填充新数据
                jwtTemp = jwt
            }
            return [ Constant.AUTHORIZATION_STR : jwt ]
        }
        else {
            return [ Constant.AUTHORIZATION_STR : jwtTemp ]
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
