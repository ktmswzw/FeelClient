//
//  LoginUserInfoViewModel.swift
//  FeelingClient
//
//  Created by Vincent on 4/5/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire


public class LoginUserInfoViewModel: BaseApi{
    
    var password = ""
    var userName = ""
    
    public weak var delegate: LoginUserModelDelegate?
    
    public init(delegate: LoginUserModelDelegate) {
        self.delegate = delegate
    }
    
    
    
    func loginDelegate(completeHander:CompletionHandlerType){
        
        NetApi().makeCallBean(Alamofire.Method.POST, section: "login", headers: [:], params: ["username": userName,"password":password,"device":"APP"]) {  (res:Response<UserInfo, NSError>) in
            switch (res.result) {
            case .Success(let value):
                if value.id.length != 0 {
                    completeHander(Result.Success(value))
                }
                else
                {
                    completeHander(Result.Failure("账号或者密码错误"))
                }
                break
            case .Failure(_):
                completeHander(Result.Failure("服务器离家出走，攻城狮在奋斗"))
                break
            }

        }
    }
    
    func register(completeHander:CompletionHandlerType){
        NetApi().makeCallBean(Alamofire.Method.POST, section: "/user/register", headers: [:], params: ["username": userName,"password":password,"device":"APP"]) { (res:Response<UserInfo, NSError>) in
            switch (res.result) {
            case .Success(let value):
                if value.id.length != 0 {
                    completeHander(Result.Success(value))
                }
                else
                {
                    completeHander(Result.Failure(value))
                }
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
    func getToken(completeHander:CompletionHandlerType)
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

public protocol LoginUserModelDelegate: class {
}
