//
//  OpenMessageModel.swift
//  FeelingClient
//
//  Created by vincent on 20/3/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation

public class OpenMessageModel {
    
    let msg: MessageApi = MessageApi.defaultMessages
    
    //id
    var id: String = ""
    //接受对象
    var to: String = ""
    //发送人
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
    
    //问题
    var question: String?
    //答案
    var answer: String?
    
    var x:Double = 0.0
    var y:Double = 0.0
    
    var msgscrent = MessagesSecret()// 内容
    var msgscrentId = "";//解密后的id
    
    func verifyAnswer(view:UIView)
    {
        msg.verifyMsg(self.id, answer: self.answer!) { (r: BaseApi.Result) -> Void in
            switch (r) {
            case .Success(let r):
                self.msgscrentId = r as! String;
                break;
            case .Failure(let msg):
                view.makeToast(msg as! String, duration: 1, position: .Top)
                break;
            }
            
        }
    }
    
    func arrival(view:UIView)
    {
        msg.arrival(msgscrentId, x: "\(x)", y: "\(y)") { (r:BaseApi.Result) -> Void in
            switch (r) {
            case .Success(let r):
                self.msgscrent = r as! MessagesSecret;
                break;
            case .Failure(let msg):
                view.makeToast(msg as! String, duration: 1, position: .Top)
                break;
            }
        }
    }
    
}


public protocol OpenMessageModelDelegate: class {
    func verifyAnswer()
}