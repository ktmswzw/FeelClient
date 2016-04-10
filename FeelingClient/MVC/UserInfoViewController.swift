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

class UserInfoViewController: DesignableViewController {
    
    var friend:FriendBean = FriendBean()
    
    @IBOutlet weak var avatar: AnimatableImageView!
    @IBOutlet weak var userId: AnimatableTextField!
    @IBOutlet weak var motto: AnimatableTextField!
    @IBOutlet weak var address: AnimatableTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let image = UIImage(named: "horse")
        let blurredImage = image!.imageByApplyingBlurWithRadius(30)
        self.view.layer.contents = blurredImage.CGImage
        
        
        self.navigationItem.title = "用户信息"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "聊天", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UserInfoViewController.privateChat))
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}