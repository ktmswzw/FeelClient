//
//  CenterMessageModel.swift
//  FeelingClient
//
//  Created by vincent on 10/3/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation
import MapKit

public class MessageViewModel {
    
    public let msgs: Messages = Messages.defaultMessages
    
    
    var selfSendMsgs = [MessageBean]()
    
    //id
    var id: String = ""
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
    var burnAfterReading: Bool = false
    
    var annotationArray = [MyAnnotation]()
    
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    
    public weak var delegate: MessageViewModelDelegate?
    
    var imageData = [UIImage]()
    
    private var index: Int = -1
    
    var isNew: Bool {
        return index == -1
    }
    
    // new initializer
    public init(delegate: MessageViewModelDelegate) {
        self.delegate = delegate
    }
    
    
    func sendMessage(se:AnyObject?) {
        let msg = MessageBean()
        msg.burnAfterReading = burnAfterReading
        msg.to = to
        msg.limitDate = limitDate
        msg.video = video
        msg.sound = sound
        msg.content = content
        msg.x = latitude
        msg.y = longitude
        
        se!.view!!.addSubview(HUD!)
        HUD!.showAnimated(true, whileExecutingBlock: { () -> Void in
            self.msgs.saveMsg(msg, imags: self.imageData) { (r:BaseApi.Result) -> Void in
                switch (r) {
                case .Success(_):
                    self.selfSendMsgs.append(msg)
                    se!.view!!.makeToast("发表成功", duration: 2, position: .Center)
                    break;
                case .Failure(_):
                    se!.view!!.makeToast("登陆失效", duration: 2, position: .Center)
                    break;
                }
                
                HUD!.removeFromSuperview()
                
                se!.navigationController?!.popViewControllerAnimated(true)
            }
            
            }) { () -> Void in
                
        }
        
        
    }
    
    
    func searchMessage(map: MKMapView) {
        msgs.searchMsg("", x: "\(latitude)", y: "\(longitude)", page: 0, size: 100) { (r:BaseApi.Result) -> Void in
            switch (r) {
            case .Success(let r):
                
                for msg in r as! [MessageBean] {
                    let oneAnnotation = MyAnnotation()
                    
                    oneAnnotation.coordinate = CLLocationCoordinate2DMake(msg.y, msg.x).toMars()
                    oneAnnotation.title = msg.to
                    oneAnnotation.subtitle = msg.question
                    oneAnnotation.id = msg.id
                    self.annotationArray.append(oneAnnotation)
                }
                map.addAnnotations(self.annotationArray)
                
                break;
            case .Failure(_):
                
                break;
            }
        }
    }
    
}

public protocol MessageViewModelDelegate: class {
    func sendMsg(sender:AnyObject)
    func searchMsg(sender: AnyObject)
}
