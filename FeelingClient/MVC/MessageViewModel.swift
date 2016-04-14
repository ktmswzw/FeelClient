//
//  MessageViewModel.swift
//  FeelingClient
//
//  Created by Vincent on 4/5/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

public class Messages:BaseApi {
    static let defaultMessages = Messages()
    var msgs = [MessageBean]()
    var imagesData: [UIImage]?
    
    func addMsg(msg: MessageBean, imags:[UIImage]) {
        msgs.insert(msg, atIndex:0)
    }
    
    func saveMsg(msg: MessageBean, imags:[UIImage],completeHander: CompletionHandlerType)
    {
        
        if imags.count==0 {
            self.sendSelf(msg, path: "",complete: completeHander)
        }
        else
        {
            
            loader.completionAll(imags) { (r:PhotoUpLoader.Result) -> Void in
                switch (r) {
                case .Success(let pathIn):
                    self.sendSelf(msg, path: pathIn as!String,complete: completeHander)
                    break;
                case .Failure(let error):
                    completeHander(Result.Failure(error))
                    break;
                }
            }
        }
    }
    
    private func sendSelf(msg: MessageBean,path: String,complete: CompletionHandlerType)
    {
        let headers = jwt.getHeader(jwt.token, myDictionary: Dictionary<String,String>())
        let params = ["to": msg.to, "limitDate":msg.limitDate, "content":msg.content,"question": msg.question, "answer": msg.answer, "photos": path,  "burnAfterReading":msg.burnAfterReading, "x": "\(msg.y)", "y":"\(msg.x)"]
        NetApi().makeCall(Alamofire.Method.POST,section: "messages/send", headers: headers, params: params as? [String : AnyObject] )
        {
            (result:BaseApi.Result) -> Void in
            complete(result)
        }
    }
    
    //    * @param to   接受人
    //    * @param x    经度
    //    * @param y    维度
    //    * @param page
    //    * @param size
    //
    func searchMsg(to: String,x: String,y:String,page:Int,size:Int,completeHander: CompletionHandlerType)
    {
        let params = ["to": to,"x": y, "y":x, "page": page,"size":size]
        NetApi().makeCallArray(Alamofire.Method.POST, section: "messages/search", headers: [:], params: params as? [String:AnyObject]) { (response: Response<[MessageBean], NSError>) -> Void in
            switch (response.result) {
            case .Success(let value):
                self.msgs = value
                completeHander(Result.Success(self.msgs))
                break;
            case .Failure(let error):
                print("\(error)")
                break;
            }
        }
    }
    
}

class MessageApi:BaseApi{
    
    static let defaultMessages = MessageApi()
    
    func verifyMsg(id: String,answer:String,completeHander: CompletionHandlerType)
    {
        let params = ["answer":answer]
        let headers = jwt.getHeader(jwt.token, myDictionary: Dictionary<String,String>())
        NetApi().makeCall(Alamofire.Method.GET, section: "messages/validate/\(id)", headers: headers, params: params) {
            (result:BaseApi.Result) -> Void in
            
            switch (result) {
            case .Success(let value):
                if let json = value {
                    let myJosn = JSON(json)
                    let code:Int = Int(myJosn["status"].stringValue)!
                    let id:String = myJosn.dictionary!["message"]!.stringValue
                    if code != 200 {
                        completeHander(Result.Failure(id))
                    }
                    else{
                        completeHander(Result.Success(id))
                    }
                }
                break;
            case .Failure(let error):
                print("\(error)")
                break;
            }
        }
    }
    
    func arrival(id: String,completeHander: CompletionHandlerType)
    {
        let params = [:]
        NetApi().makeCallBean(Alamofire.Method.GET, section: "messages/openOver/\(id)", headers: [:], params: (params as! [String : AnyObject])) { (res:Response<MessagesSecret, NSError>) in
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