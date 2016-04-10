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

class UserInfoViewController: DesignableViewController {
    
    var friend:FriendBean = FriendBean()
    
    var viewModel: FriendViewModel!
    @IBOutlet weak var avatar: AnimatableImageView!
    @IBOutlet weak var userId: AnimatableTextField!
    @IBOutlet weak var motto: AnimatableTextField!
    @IBOutlet weak var address: AnimatableTextField!
    @IBOutlet weak var chatButton: AnimatableButton!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = FriendViewModel(delegate: self)
        
        let image = UIImage(named: "horse")
        let blurredImage = image!.imageByApplyingBlurWithRadius(50)
        self.view.layer.contents = blurredImage.CGImage
        
        
        self.navigationItem.title = "用户信息"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UserInfoViewController.saveFriend))
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        
        let database = SwiftyDB(databaseName: "UserInfo")
        
        let list = database.objectsForType(UserInfo.self, matchingFilter: ["id": friend.user]).value!
        
        if list.count > 0 {
            let userinfo = list[0]
            
            self.avatar.hnk_setImageFromURL(NSURL(string:userinfo.avatar)!)
            self.userId.text = userinfo.nickname
            self.motto.text = userinfo.phone
            self.address.text = userinfo.region
        }
        else{
            self.avatar.hnk_setImageFromURL(NSURL(string:friend.avatar)!)
            self.userId.text = self.friend.remark
            self.motto.text = self.friend.motto
            self.address.text = ""
        }
        // Do any additional setup after loading the view.
        
        
        //点击
        chatButton.rx_tap
            .subscribeNext { [weak self] in self?.privateChat() }
            .addDisposableTo(disposeBag)

    }
    
    func saveFriend() {
        if self.userId.text?.length > 0 {
            self.navigationItem.rightBarButtonItem?.enabled = false
            viewModel.remark(self.friend.id, name: self.userId.text!) { (r:BaseApi.Result) in
                switch (r) {
                case .Success(_):
                    self.view.makeToast("保存成功", duration: 2, position: .Center)
                    self.navigationItem.rightBarButtonItem?.enabled = true
                    break;
                case .Failure(let msg):
                    self.view.makeToast("保存失败\(msg)", duration: 2, position: .Center)
                    break;
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
}
extension UserInfoViewController: FriendModelDelegate{
    
}