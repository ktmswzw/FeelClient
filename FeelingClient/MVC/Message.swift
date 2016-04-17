//
//  Message.swift
//  FeelingClient
//
//  Created by vincent on 9/3/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation
import ObjectMapper


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
        address <- map["address"]
        point <- map["point"]
        fromId <- map["fromId"]
        avatar <- map["avatar"]
        
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
    var photos: [String] = []
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
    var fromId = ""
    var avatar = "" //头像地址
    var address = ""
    //问题
    var question: String = ""
    var answer: String = ""
    
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
    var photos: [String] = []
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