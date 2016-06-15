//
//  UserInfoViewController.swift
//  FeelingClient
//
//  Created by Vincent on 4/7/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit
import SwiftyDB
import IBAnimatable
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif
import Eureka

var imageViewFriend = UIImageView(image: UIImage(named: "agirl"))

class UserInfoViewController: FormViewController {
    
    var friend:FriendBean = FriendBean()
    
    var viewModel: FriendViewModel!
    
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = FriendViewModel(delegate: self)
        
        let image = UIImage(named: "agirl")
        let blurredImage = image!.imageByApplyingBlurWithRadius(50)
        self.view.layer.contents = blurredImage.CGImage
        var tmp = ""
        
        self.navigationItem.title = "用户信息"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UserInfoViewController.saveFriend))
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        
        let database = SwiftyDB(databaseName: "UserInfo")
        
        let list = database.objectsForType(UserInfo.self, matchingFilter: ["id": friend.user]).value!
        
        if list.count > 0 {
            let userinfo = list[0]
            imageViewFriend.hnk_setImageFromURL(NSURL(string:userinfo.avatar)!)
            
            if userinfo.register {
                tmp = userinfo.phone
            }
            
            form = Section() {
                $0.header = HeaderFooterView<EurekaFriendView>(HeaderFooterProvider.Class)
                }
                
                +++ Section()
                <<< TextRow("remark"){
                    $0.title = "备注"
                    $0.value = self.friend.remark
                }
                <<< PhoneRow("phone"){
                    $0.title = "手机"
                    $0.disabled = true
                    $0.value = tmp
                }
                <<< TextRow("realname") {
                    $0.title = "姓名"
                    $0.disabled = true
                    $0.placeholder = "真实姓名"
                }
                <<< TextRow("nickname") {
                    $0.title = "昵称"
                    $0.value = userinfo.nickname
                    $0.disabled = true
                    $0.placeholder = "朋友或亲人对你的昵称"
                }
                <<< TextRow("sex") {
                    $0.title = "性别"                    
                    $0.value = getSex(userinfo.sex)
                    $0.disabled = true
                }
                <<< TextRow("mommo") {
                    $0.title = "签名"
                    $0.value = userinfo.motto
                    $0.disabled = true
                }
                
                +++ Section()
                <<< ButtonRow() { (row: ButtonRow) -> Void in
                    row.title = "和TA聊天"
                    }  .onCellSelection({ (cell, row) in
                        self.privateChat()
                    })
            
        }else{
            
            imageViewFriend.hnk_setImageFromURL(NSURL(string:self.friend.avatar)!)
            
            form = Section() {
                $0.header = HeaderFooterView<EurekaFriendView>(HeaderFooterProvider.Class)
                }
                
                +++ Section()
                <<< TextRow("remark"){ $0.title = "备注"
                    $0.value = self.friend.remark
                }
                <<< TextRow("mommo") {$0.title = "签名"
                    $0.value = self.friend.motto
                    $0.disabled = true
                }
                +++ Section()
                <<< ButtonRow() { (row: ButtonRow) -> Void in
                    row.title = "和TA聊天"
                    }  .onCellSelection({ (cell, row) in
                        self.privateChat()
                    })
        }
        
    }
    
    func saveFriend() {        
        if let remarkText =  form.rowByTag("remark")?.baseValue as? String {
            self.navigationController?.view.makeToastActivity(.Center)
            if remarkText.length > 0 {
                self.navigationItem.rightBarButtonItem?.enabled = false
                viewModel.remark(self.friend.id, name: remarkText) { (r:BaseApi.Result) in
                    switch (r) {
                    case .Success(_):
                        self.navigationController?.view.hideToastActivity()
                        
                        self.view.makeToast("保存成功", duration: 2, position: .Center)
                        self.navigationItem.rightBarButtonItem?.enabled = true
                        break;
                    case .Failure(let msg):
                        self.navigationController?.view.hideToastActivity()
                        self.view.makeToast("保存失败\(msg)", duration: 2, position: .Center)
                        break;
                    }
                }
            }
        }
        else
        {
            self.view.makeToast("填写备注", duration: 2, position: .Center)
        }
    }
    
    func privateChat() {
        //打开会话界面
        let chat = RCConversationViewController(conversationType: RCConversationType.ConversationType_PRIVATE, targetId: self.friend.user)
        chat.title = "\(friend.remark)"
        chat.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(chat, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}
extension UserInfoViewController: FriendModelDelegate{
    
}
class EurekaFriendView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageViewFriend.frame = CGRect(x: 0, y: 0, width: 130, height: 130)
        imageViewFriend.autoresizingMask = .FlexibleBottomMargin
        let bounds = UIScreen.mainScreen().bounds
        let width = bounds.size.width
        self.frame = CGRect(x: 0, y: 0, width: width, height: 140)
        imageViewFriend.center = CGPointMake(self.frame.size.width  / 2, (self.frame.size.height / 2) + 15 )
        imageViewFriend.contentMode = .ScaleAspectFit
        imageViewFriend.layer.masksToBounds = true
        imageViewFriend.layer.cornerRadius = 5
        self.addSubview(imageViewFriend)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}