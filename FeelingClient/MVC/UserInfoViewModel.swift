//
//  UserInfoViewModel.swift
//  FeelingClient
//
//  Created by Vincent on 16/4/4.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

public class UserInfoViewModel:BaseApi {
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
    var user_id = ""
    /// 用户头像
    var face_image_entity : UIImage! = UIImage(named: "default_user_head")
     /// id
    var id = ""
    
    public weak var delegate: UserInfoModelDelegate?
    
    public init(delegate: UserInfoModelDelegate) {
        self.delegate = delegate
    }
    
    /**
     获取用户信息
     
     - parameter sender:         sender description
     - parameter completeHander: completeHander description
     */
    func getUser(sender: AnyObject,completeHander:CompletionHandlerType)
    {
        let params = [:]
        let headers = jwt.getHeader(jwt.token, myDictionary: Dictionary<String,String>())
        NetApi().makeCallBean(Alamofire.Method.GET, section: "\(self.id)", headers: headers, params: (params as! [String : AnyObject])) { (res:Response<UserInfo, NSError>) in
            switch (res.result) {
            case .Success(let value):
                completeHander(Result.Success(value))
                break
            case .Failure(let error):
                completeHander(Result.Failure(error))
                break
            }
        }
    }
    
    /**
     保存用户
     
     - parameter sender:         sender description
     - parameter completeHander: completeHander description
     */
    func saveUser(sender: AnyObject,completeHander:CompletionHandlerType)
    {
        let params = ["nickname":self.nickname,"phone":self.phone,"sex":self.sex,"avatar":self.avatar]
        let headers = jwt.getHeader(jwt.token, myDictionary: Dictionary<String,String>())
        NetApi().makeCallBean(Alamofire.Method.PATCH, section: "\(self.id)", headers: headers, params: params) { (res:Response<UserInfo, NSError>) in
            switch (res.result) {
            case .Success(let value):
                completeHander(Result.Success(value))
                break
            case .Failure(let error):
                completeHander(Result.Failure(error))
                break
            }
        }
    }
    }

public protocol UserInfoModelDelegate: class {
    func getUser(sender: AnyObject)
    func saveUser(sender: AnyObject)
}

