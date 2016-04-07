//
//  UserInfoViewController.swift
//  FeelingClient
//
//  Created by Vincent on 4/7/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController {
    
    
    @IBOutlet weak var userId: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "用户信息"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "聊天", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UserInfoViewController.privateChat))
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
    }
    
    func privateChat() {
        
        //打开会话界面
        let chat = RCConversationViewController(conversationType: RCConversationType.ConversationType_PRIVATE, targetId: self.userId.text)
        chat.title = "想显示的会话标题"
        
        chat.hidesBottomBarWhenPushed = true
        
        //chat.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
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
