//
//  ChatViewController.swift
//  FeelingClient
//
//  Created by vincent on 13/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit

import SwiftyDB
import IBAnimatable

class ChatViewController: RCConversationListViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()
        sleep(1)
        //设置需要显示哪些类型的会话
        self.setDisplayConversationTypes([RCConversationType.ConversationType_PRIVATE.rawValue,
            RCConversationType.ConversationType_DISCUSSION.rawValue,
            RCConversationType.ConversationType_CHATROOM.rawValue,
            RCConversationType.ConversationType_GROUP.rawValue,
            RCConversationType.ConversationType_APPSERVICE.rawValue,
            RCConversationType.ConversationType_SYSTEM.rawValue])
        //设置需要将哪些类型的会话在会话列表中聚合显示
        self.setCollectionConversationType([RCConversationType.ConversationType_DISCUSSION.rawValue,
            RCConversationType.ConversationType_GROUP.rawValue])
        
        self.title = "聊天"
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loginRIM()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //重写RCConversationListViewController的onSelectedTableRow事件
    override func onSelectedTableRow(conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, atIndexPath indexPath: NSIndexPath!) {
        
        //打开会话界面
        let chat = RCConversationViewController(conversationType: model.conversationType, targetId: model.targetId)
        let database = SwiftyDB(databaseName: "UserInfo")
        let list = database.objectsForType(UserInfo.self, matchingFilter: ["id": model.targetId]).value!
        if list.count > 0 {
            let userinfo = list[0]
            chat.title = "\(userinfo.nickname)"
            
            RCIM.sharedRCIM().refreshUserInfoCache(RCUserInfo(userId: userinfo.id, name: userinfo.nickname, portrait: userinfo.avatar), withUserId: userinfo.id)
            
        }
        chat.hidesBottomBarWhenPushed = true
        
        
        //chat.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.pushViewController(chat, animated: true)
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


extension RCConversationViewController{
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}