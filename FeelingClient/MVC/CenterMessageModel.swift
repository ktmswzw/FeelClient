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
    
    
    func sendMessage() {
        let msg = MessageBean()
        msg.burnAfterReading = burnAfterReading
        msg.to = to
        msg.limitDate = limitDate
        msg.video = video
        msg.sound = sound
        msg.content = content
        msg.x = latitude
        msg.y = longitude
        msgs.saveMsg(msg, imags: imageData) { (r:BaseApi.Result) -> Void in
            switch (r) {
            case .Success(let r):
                self.id = r as! String
                break;
            case .Failure(_):
                
                break;
            }
        }
    }
    
    func searchMessage(map: MKMapView) {
        msgs.searchMsg("", x: "\(latitude)", y: "\(longitude)", page: 0, size: 100) { (r:BaseApi.Result) -> Void in
            switch (r) {
            case .Success(let r):
                for msg in r as! [MessageBean] {
                    
                    let oneAnnotation = MyAnnotation()
                    
                    oneAnnotation.coordinate = CLLocationCoordinate2DMake(msg.y, msg.x)
                    oneAnnotation.title = msg.to
                    oneAnnotation.subtitle = msg.content
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
    func sendMessage()
    func searchMessage()
}
