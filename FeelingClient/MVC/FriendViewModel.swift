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
    
    
    let params = [:]
    let headers = jwt.getHeader(jwt.token, myDictionary: Dictionary<String,String>())
    
    func save(completeHander:CompletionHandlerType){
        NetApi().makeCallBean(Alamofire.Method.POST, section: "friend/\(self.user)", headers: headers, params: params as? [String:AnyObject]) { (res:Response<UserInfo, NSError>) in
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
    
    func black(completeHander:CompletionHandlerType){
        NetApi().makeCallBean(Alamofire.Method.DELETE, section: "friend/\(self.user)", headers: headers, params: params as? [String:AnyObject]) { (res:Response<UserInfo, NSError>) in
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
    
    func searchMsg(name: String,completeHander: CompletionHandlerType)
    {
        NetApi().makeCallArray(Alamofire.Method.GET, section: "/\(self.remark)", headers: headers, params: params as? [String:AnyObject]) { (response: Response<[FriendBean], NSError>) -> Void in
            switch (response.result) {
            case .Success(let value):
                self.friends = value
                completeHander(Result.Success(self.friends))
                break;
            case .Failure(let error):
                print("\(error)")
                break;
            }
        }
    }
    
}



public protocol FriendModelDelegate: class {
    func save()
    func black()
    func search(name:String)
}
