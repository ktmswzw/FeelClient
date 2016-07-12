//
//  CenterMessageModel.swift
//  FeelingClient
//
//  Created by vincent on 10/3/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation
import MapKit

import Chirp

public class MessageViewModel {
    
    public let msgs: Messages = Messages.defaultMessages
    
    
    var selfSendMsgs = [MessageBean]()
    
    //id
    var id: String = ""
    //msgId
    var msgId = ""
    //问题
    var question = ""
    //答案
    var answer = ""
    //接受对象
    var to: String = ""
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
    var burnAfterReading: Bool = true
    
    var annotationArray = [MyAnnotation]()
    
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    
    //发起人id
    var fromId = ""
    
    public weak var delegate: MessageViewModelDelegate?
    
    var imageData = [UIImage]()
    
    var imageDataThumbnail = [UIImage]()
    
    private var index: Int = -1
    
    var isNew: Bool {
        return index == -1
    }
    
    var address = ""
    
    // new initializer
    public init(delegate: MessageViewModelDelegate) {
        self.delegate = delegate
    }
    
    
    func sendMessage(se:AnyObject?) {
        let msg = MessageBean()
        msg.to = to
        msg.video = video
        msg.sound = sound
        msg.content = content
        msg.x = latitude
        msg.y = longitude
        msg.question = question
        msg.answer = answer
        msg.address = address
        msg.burnAfterReading = burnAfterReading
        self.msgs.saveMsg(msg, imags: self.imageData) { (r:BaseApi.Result) -> Void in
            switch (r) {
            case .Success(let value):
                print(value)
                self.selfSendMsgs.append(msg)
                se!.navigationController!!.view.hideToastActivity()
                se!.view!!.makeToast("发表成功", duration: 2, position: .Center)
                se!.navigationController?!.popViewControllerAnimated(true)
                Chirp.sharedManager.playSound(fileName: "send.wav")
                break;
            case .Failure(let value):
                print(value)
                self.selfSendMsgs.append(msg)
                se!.navigationController!!.view.hideToastActivity()
                se!.view!!.makeToast("发表失败,长时间未使用，请重新登录", duration: 2, position: .Center)
                break;
            }
        }
    }
    
    
    func searchMessage(to:String, map: MKMapView, view: UIView) {
        view.makeToastActivity(.Center)
        msgs.searchMsg(to, x: "\(latitude)", y: "\(longitude)", page: 0, size: 100) { (r:BaseApi.Result) -> Void in
            switch (r) {
            case .Success(let r):
                self.annotationArray.removeAll()
                if let msgs = r  {
                    if(msgs.count==0){
                        Chirp.sharedManager.playSound(fileName: "no.wav")
                        view.makeToast("未找到你想要信件", duration: 2, position: .Center)
                    }
                    else{
                        for msg in r as! [MessageBean] {
                            let oneAnnotation = MyAnnotation()
                            
                            oneAnnotation.original_coordinate = CLLocationCoordinate2DMake(msg.y, msg.x)
                            oneAnnotation.coordinate = CLLocationCoordinate2DMake(msg.y, msg.x).toMars()// 转换火星地图
                            oneAnnotation.title =  "\(msg.from)"
                            oneAnnotation.question = "问题：\(msg.question)"
                            oneAnnotation.id = msg.id
                            oneAnnotation.url = msg.avatar
                            oneAnnotation.address = msg.address
                            oneAnnotation.fromId = msg.fromId
                            oneAnnotation.answerTip = msg.answerTip
                            oneAnnotation.type = msg.type
                            
                            self.annotationArray.append(oneAnnotation)
                        }
                        map.addAnnotations(self.annotationArray)                        
                        Chirp.sharedManager.playSound(fileName: "got.wav")
                        view.makeToast("共找到 \(msgs.count) 封未开启信件", duration: 1, position: .Center)
                    }
                }
                view.hideToastActivity();
                break;
            case .Failure(_):
                view.hideToastActivity();
                view.makeToast("长时间未使用，请重新登录", duration: 2, position: .Center)
                break;
            }
        }
    }
    
}

public protocol MessageViewModelDelegate: class {
}
