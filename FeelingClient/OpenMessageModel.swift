//
//  OpenMessageModel.swift
//  FeelingClient
//
//  Created by vincent on 20/3/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation

public class OpenMessageModel:BaseApi {
    
    let msg: MessageBean = MessageBean()
    
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
    
    var x:Double = 0.0
    var y:Double = 0.0
    
    func verifyAnswer()
    {
        
    }
    
}


public protocol OpenMessageModelDelegate: class {
    func verifyAnswer()
}