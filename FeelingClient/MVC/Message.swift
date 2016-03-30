//
//  Message.swift
//  FeelingClient
//
//  Created by vincent on 9/3/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation
import ObjectMapper

import SwiftyJSON
import Alamofire

var jwt = JWTTools()

public class Messages:BaseApi {
    static let defaultMessages = Messages()
    var msgs = [MessageBean]()
    var loader = PhotoUpLoader.init()
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
        let params = ["to": msg.to,"limitDate":msg.limitDate,"content":msg.content, "photos": path,  "burnAfterReading":msg.burnAfterReading, "x": "\(msg.y)", "y":"\(msg.x)"]
        NetApi().makeCall(Alamofire.Method.POST,section: "messages/send", headers: headers, params: params as? [String : AnyObject] , completionHandler: complete)
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
    //    /messages/arrival/{x}/{y}/{id}
    //    /messages/validate/{id}/{answer}
    func verifyMsg(id: String,answer:String,completeHander: CompletionHandlerType)
    {
        let params = [:]
        let headers = jwt.getHeader(jwt.token, myDictionary: Dictionary<String,String>())
        NetApi().makeCall(Alamofire.Method.GET, section: "messages/validate/\(id)/\(answer)", headers: headers, params: params as? [String:AnyObject]) {
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
    
    func arrival(id: String,x: String,y:String,completeHander: CompletionHandlerType)
    {
        let params = [:]
        NetApi().makeCall(Alamofire.Method.POST, section: "arrival/\(y)/\(x)/\(id)", headers: [:], params: params as? [String:AnyObject]) {
            (result:BaseApi.Result) -> Void in
            
            switch (result) {
            case .Success(let value):
                if let json = value {
                    let myJosn = JSON(json)
                    let code:Int = Int(myJosn["status"].stringValue)!
                    if code != 200 {
                        let bean:MessagesSecret =  json["message"] as! MessagesSecret
                        completeHander(Result.Success(bean))
                    }
                    else{
                        completeHander(Result.Failure(""))
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

class MessageBean: BaseModel {
    
    override static func newInstance() -> Mappable {
        return MessageBean();
    }
    
    override func mapping(map: Map) {
        
        super.mapping(map)
        id <- map["id"]
        to <- map["to"]
        from <- map["from"]
        limitDate <- map["limit_date"]
        content <- map["content"]
        //photos <- map["photos"]
        video <- map["videoPath"]
        sound <- map["soundPath"]
        burnAfterReading <- map["burn_after_reading"]
        x <- map["x"]
        y <- map["y"]
        question <- map["question"]
        distance <- map["distance"]
        point <- map["point"]
        
    }
    
    var id: String = ""
    //接受对象
    var to: String = ""
    //
    var from: String = ""
    //期限
    var limitDate: String = ""
    //内容
    var content: String = ""
    //图片地址
    var photos: [String] = [""]
    //视频地址
    var video: String = ""
    //音频地址
    var sound: String = ""
    //阅后即焚
    var burnAfterReading: Bool = false
    //坐标
    var x: Double = 0.0
    //坐标
    var y: Double = 0.0
    //距离
    var distance: Double = 0.0
    
    //问题
    var question: String?
    var point: GeoJsonPoint?
    
}
//坐标点
class GeoJsonPoint:BaseModel {
    //坐标
    var x: Double = 0.0
    //坐标
    var y: Double = 0.0
    
    override static func newInstance() -> Mappable {
        return GeoJsonPoint();
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        x <- map["x"]
        y <- map["y"]
    }
}
//解密消息
class MessagesSecret:BaseModel {
    
    var msgId: String?
    //期限
    var limitDate: String?
    //内容
    var content: String?
    //图片地址
    var photos: [String] = [""]
    //视频地址
    var video: String?
    //音频地址
    var sound: String?
    //阅后即焚
    var burnAfterReading: Bool = false
    //答案
    var answer: String?
    
    
    override static func newInstance() -> Mappable {
        return MessagesSecret();
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        limitDate <- map["limit_date"]
        content <- map["content"]
        photos <- map["photos"]
        video <- map["videoPath"]
        sound <- map["soundPath"]
        answer <- map["answer"]
        burnAfterReading <- map["burn_after_reading"]
        
    }
}