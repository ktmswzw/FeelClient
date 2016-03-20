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


public class Messages:BaseApi {
    static let defaultMessages = Messages()
    var msgs = [MessageBean]()
    var msgscrent = MessagesSecret()// 内容
    var msgscrentId = "";//解密后的id
    var loader = PhotoUpLoader.init()
    
    var jwt = JWTTools()
    var imagesData: [UIImage]?
    
    func addMsg(msg: MessageBean, imags:[UIImage]) {
        msgs.insert(msg, atIndex:0)
    }
    
    func saveMsg(msg: MessageBean, imags:[UIImage],completeHander: CompletionHandlerType)
    {
        
        let newDict = Dictionary<String,String>()
        let headers = jwt.getHeader(jwt.token, myDictionary: newDict)
        loader.completionAll(imags) { (r:PhotoUpLoader.Result) -> Void in
            switch (r) {
            case .Success(let pathIn):
                let params = ["to": msg.to,"limitDate":msg.limitDate,"content":msg.content, "photos":pathIn as!String,  "burnAfterReading":msg.burnAfterReading, "x": "\(msg.y)", "y":"\(msg.x)"]
                NetApi().makeCall(Alamofire.Method.POST,section: "messages/send", headers: headers, params: params as? [String : AnyObject] , completionHandler: { (result:BaseApi.Result) -> Void in
                    switch (result) {
                    case .Success(let r):
                        if let json = r {
                            let myJosn = JSON(json)
                            let code:Int = Int(myJosn["status"].stringValue)!
                            let result = myJosn.dictionary!["message"]!.stringValue
                            if code != 200 {
                                completeHander(Result.Success(result))
                            }
                            else{
                                msg.id = result
                                completeHander(Result.Failure(result))
                            }
                        }
                        self.msgs.append(msg)
                        break;
                    case .Failure(let error):
                        print("\(error)")
                        break;
                    }
                })
                
                break;
            case .Failure(let error):
                print("\(error)")
                break;
            }
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
    
//    /arrival/{x}/{y}/{id}
//    validate/{id}/{answer}
    func verifyMsg(id: String,x: String,y:String,answer:String,completeHander: CompletionHandlerType)
    {
        let params = [:]
        NetApi().makeCallArray(Alamofire.Method.POST, section: "validate/\(id)/\(answer)", headers: [:], params: params as? [String:AnyObject]) { (response: Response<[MessageBean], NSError>) -> Void in
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
    //问题
    var question: String?
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
        question <- map["question"]
        sound <- map["soundPath"]
        answer <- map["answer"]
        burnAfterReading <- map["burn_after_reading"]
        
    }
}