//
//  FriendViewModel.swift
//  FeelingClient
//
//  Created by Vincent on 4/6/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

public class FriendViewModel:BaseApi {
    
    var friends = [FriendBean]()
    
    var id: String = ""
    
    var keyUserId = ""
    
    var grouping = "";
    
    var blacklist = false;
    
    var user = "";
    
    var remark = "";
    
    
    public weak var delegate: FriendModelDelegate?
    
    public init(delegate: FriendModelDelegate) {
        self.delegate = delegate
    }
    
    
    var params = [:]
    let headers = jwt.getHeader(jwt.token, myDictionary: Dictionary<String,String>())
    
    
    /**
     保存好友
     
     - parameter id:             id description
     - parameter completeHander: completeHander description
     */
    func save(id:String, completeHander:CompletionHandlerType){
        NetApi().makeCallBean(Alamofire.Method.POST, section: "friend/\(id)/friend", headers: headers, params: params as? [String:AnyObject]) { (res:Response<UserInfo, NSError>) in
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
    
    
    func remark(id:String,name:String,completeHander:CompletionHandlerType){
        NetApi().makeCallBean(Alamofire.Method.POST, section: "friend/remark/\(id)/\(name)", headers: headers, params: params as? [String:AnyObject]) { (res:Response<UserInfo, NSError>) in
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
     拉黑删除
     
     - parameter id:             id description
     - parameter completeHander: completeHander description
     */
    func black(id:String,completeHander:CompletionHandlerType){
        NetApi().makeCallBean(Alamofire.Method.DELETE, section: "friend/\(id)", headers: headers, params: params as? [String:AnyObject]) { (res:Response<UserInfo, NSError>) in
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
     查找
     
     - parameter name:           name description
     - parameter completeHander: completeHander description
     */
    func searchMsg(name: String,completeHander: CompletionHandlerType)
    {
        let params2 = ["name":name]
        NetApi().makeCallArray(Alamofire.Method.GET, section: "friend", headers: headers, params: params2) { (response: Response<[FriendBean], NSError>) -> Void in
            switch (response.result) {
            case .Success(let value):
                self.friends = value
                completeHander(Result.Success(self.friends))
                break;
            case .Failure(let error):
                completeHander(Result.Failure(error))
                break;
            }
        }
    }
    
}
public protocol FriendModelDelegate: class {
}
