//
//  AccountModel.swift
//  MLShenZhen
//
//  Created by hcf on 15/8/31.
//  Copyright (c) 2015年 HCFData. All rights reserved.
//

import Foundation
import ObjectMapper
/**
    
    账号登录信息
    v1.0
    Y0 2015.8.31
*/
class AccountModel : BaseModel {
    
    /// token
    var token : String = ""
    /// 用户信息
    var user_info : UserInfo? = UserInfo()
    
    var user_info_copy : UserInfo?
    /// 0,未登录 ,1,已登录 ,2,第三方登录 101,token登录失败, 102,网络不通(离线)
    var loginState : Int {
        
        get{
            return token.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 ? 1 : 0
        }
    }
    /// 登录渠道 0,正常登录, 1,QQ登录, 2,微信登录
    var channel : Int = 0
    
    override class func newInstance() -> Mappable {
        return AccountModel()
    }
    /// 此处字段映射需注意:注册成功只有 token返回, 登录成功有 token+ 用户信息, 请求用户信息只有用户信息返回
    override func mapping(map: Map) {
        
        token <- map["token"]
        user_info <- map["user_info"]
    }
}

/**

    用户信息

*/
class UserInfo : BaseModel {
    
    override static func newInstance() -> Mappable {
        return UserInfo();
    }
    
    override func mapping(map: Map) {
        
        super.mapping(map)
        avatar <- map["avatar"]
        phone <- map["phone"]
        nickname <- map["nickname"]
        region <- map["region"]
        sex <- map["sex"]
        id <- map["id"]
        IMToken <- map["imtoken"]
        JWTToken <- map["jwttoken"]

    }
    
    static let TABLE_NAME = "USER_INFO"
    
    /// 头像图片地址
    var avatar = ""
    /// 手机号
    var phone : String = ""
    /// 昵称
    var nickname = ""
    /// 地区
    var region = ""
    /// 性别(1：男，2：女)
    var sex = ""
    /// 用户id
    var id = ""
    
    var IMToken = ""
    
    var JWTToken = ""
    
    
    //MARK: - private
    /**
    修改资料成功,发送一个广播通知
    */
    private func pushMsg(notifyKey : String) {
        if NSThread.isMainThread() {
            
            NSNotificationCenter.defaultCenter().postNotificationName(notifyKey, object: nil)
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                NSNotificationCenter.defaultCenter().postNotificationName(notifyKey, object: nil)
            })
        }
    }
}
