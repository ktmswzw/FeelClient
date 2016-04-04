//
//  UserInfoViewModel.swift
//  FeelingClient
//
//  Created by Vincent on 16/4/4.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import Foundation
import ObjectMapper
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
    
    /**
     获取imtoken
     
     - parameter sender:         sender description
     - parameter completeHander: completeHander description
     */
    func getToken(sender: AnyObject,completeHander:CompletionHandlerType)
    {
        let params = [:]
        let headers = jwt.getHeader(jwt.token, myDictionary: Dictionary<String,String>())
        NetApi().makeCall(Alamofire.Method.GET, section: "IMToken", headers: headers, params: params as? [String:AnyObject]) {
            (result:BaseApi.Result) -> Void in
            
            switch (result) {
            case .Success(let value):
                if let json = value {
                    let myJosn = JSON(json)
                    let code:Int = Int(myJosn["status"].stringValue)!
                    let imtoken:String = myJosn.dictionary!["message"]!.stringValue
                    if code != 200 {
                        completeHander(Result.Failure(imtoken))
                    }
                    else{
                        RCIM.sharedRCIM().connectWithToken(imtoken,
                                                           success: { (userId) -> Void in
                                                            print("登陆成功。当前登录的用户ID：\(userId)")
                            }, error: { (status) -> Void in
                                print("登陆的错误码为:\(status.rawValue)")
                            }, tokenIncorrect: {
                                //token过期或者不正确。
                                //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
                                //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
                                print("token错误")
                        })
                        completeHander(Result.Success(imtoken))
                    }
                }
                break;
            case .Failure(let error):
                print("\(error)")
                break;
            }
        }
    }
}

public protocol UserInfoModelDelegate: class {
    func getUser(sender: AnyObject)
    func saveUser(sender: AnyObject)
    func getToken(sender: AnyObject)
}

