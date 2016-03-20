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
class UserInfo : BaseModel, NSCopying {
    
    override static func newInstance() -> Mappable {
        return UserInfo();
    }
    
    override func mapping(map: Map) {
        
        super.mapping(map)
        face_image <- map["face_image"]
        mobile <- map["mobile"]
        nickname <- map["nickname"]
        region <- map["region"]
        score <- map["score"]
        sex <- map["sex"]
        user_id <- map["user_id"]

    }
    
    /// 头像图片地址
    var face_image = ""
    /// 手机号
    var mobile : String = ""
    /// 昵称
    var nickname = ""
    /// 地区
    var region = ""
    /// 用户积分
    var score = ""
    /// 性别(1：男，2：女)
    var sex = ""
    /// 用户id
    var user_id = ""
    /// 用户头像
    var face_image_entity : UIImage! = UIImage(named: "default_user_head")
    
    /**
    不覆盖原有对象的情况下更新用户
        保证信息完整性
    
    :param: newUser newUser description
    */
    func update(newUser : UserInfo?) {
        
        if newUser == nil {
            
            NSLog("newUser is nil")
            return
        }
        if user_id != newUser!.user_id {
            
            NSLog("用户id不一致 : user_id \(user_id) newUser.user_id \(newUser!.user_id)")
        }
        
        face_image = newUser!.face_image
        mobile = newUser!.mobile
        nickname = newUser!.nickname
        region = newUser!.region
        score = newUser!.score
        sex = newUser!.sex
    }
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
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        
        let newUser = UserInfo()
        
        newUser.face_image = face_image
        newUser.mobile = mobile
        newUser.nickname = nickname
        newUser.region = region
        newUser.score = score
        newUser.sex = sex
        newUser.face_image_entity = face_image_entity.copy() as! UIImage
        
        return newUser
    }
}

/**
    请求 data 返回模型

**/
class AccountResponseModel : BaseModel {
    
    var accountModel: AccountModel!
    
    override static func newInstance() -> Mappable {
        
        return AccountResponseModel();
    }
    
    override func mapping(map: Map) {
        
        super.mapping(map)
        accountModel <- map["data"]
    }
}

/**

    获取用户信息响应模型

*/
class UserInfoResponse : BaseModel {
    
    var user_info : UserInfo!
    
    override static func newInstance() -> Mappable {
        
        return UserInfoResponse();
    }
    
    override func mapping(map: Map) {
        
        super.mapping(map)
        user_info <- map["data"]
    }

}

/**

更新用户信息响应模型

*/
class UserInfoUpdateResponse : BaseModel {
    
    var user_info : UserInfo!
    
    override static func newInstance() -> Mappable {
        
        return UserInfoUpdateResponse();
    }
    
    override func mapping(map: Map) {
        
        super.mapping(map)
        user_info <- map["user_info"]
    }
    
}