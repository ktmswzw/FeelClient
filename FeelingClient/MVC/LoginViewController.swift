//
//  LoginViewController.swift
//  FeelingClient
//
//  Created by vincent on 13/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit
import IBAnimatable
import SwiftyJSON
import Alamofire

class LoginViewController: DesignableViewController,UITextFieldDelegate {
    
    
    @IBOutlet var username: AnimatableTextField!
    @IBOutlet var password: AnimatableTextField!
    
    var actionButton: ActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "lonely-children")
        let blurredImage = image!.imageByApplyingBlurWithRadius(3)
        self.view.layer.contents = blurredImage.CGImage
        
        let register = ActionButtonItem(title: "注册帐号", image: UIImage(named: "new")!)
        register.action = { item in
            self.performSegueWithIdentifier("register", sender: self)
        }
        //        let forget = ActionButtonItem(title: "忘记密码", image: UIImage(named: "new")!)
        //        forget.action = { item in }
        //        let wechatLogin = ActionButtonItem(title: "微信登录", image: UIImage(named: "wechat")!)
        //        wechatLogin.action = { item in   }
        //        let qqLogin = ActionButtonItem(title: "QQ登录", image: UIImage(named: "qq")!)
        //        qqLogin.action = { item in }
        //        let weiboLogin = ActionButtonItem(title: "微博登录", image: UIImage(named: "weibo")!)
        //        weiboLogin.action = { item in  }
        //        let taobaoLogin = ActionButtonItem(title: "淘宝登录", image: UIImage(named: "taobao")!)
        //        taobaoLogin.action = { item in
        //        }
        //        actionButton = ActionButton(attachedToView: self.view, items: [register, forget, wechatLogin, qqLogin, weiboLogin, taobaoLogin])
        actionButton = ActionButton(attachedToView: self.view, items: [register])
        actionButton.action = { button in button.toggleMenu() }
        actionButton.setImage(UIImage(named: "new"), forState: .Normal)
        actionButton.backgroundColor = UIColor.lightGrayColor()
        
        username.delegate = self
        password.delegate = self
        
        HUD = MBProgressHUD(view: self.view)
        self.view.addSubview(HUD!)
        HUD!.mode = .AnnularIndeterminate
        
    }
    
    
    override func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField === username) {
            password.becomeFirstResponder()
        } else if (textField === password) {
            password.resignFirstResponder()
            self.login(self)
        } else {
            // etc
        }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func login(sender: AnyObject) {
        
        if username.text != "" && password.text != ""
        {
            if !self.password.validatePassword() {
                self.view.makeToast("密码必选大于6位数小于18的数字或字符", duration: 2, position: .Center)
                return
            }
            else{
                //123456789001
                //123456
                let userNameText = username.text
                let passwordText = password.text!.md5()
                selfLogin(userNameText!, password: passwordText!)
            }
            
        }
        else
        {
            self.view.makeToast("帐号或密码为空", duration: 2, position: .Center)
        }
        
    }
    
    private func selfLogin(userName:String,password:String){
        HUD!.showAnimated(true, whileExecutingBlock: { () -> Void in
            NetApi().makeCall(Alamofire.Method.POST, section: "login", headers: [:], params: ["username": userName,"password":password,"device":"APP"], completionHandler: { (result:BaseApi.Result) -> Void in
                switch (result) {
                case .Success(let r):
                    if let json = r {
                        let myJosn = JSON(json)
                        let code:Int = Int(myJosn["status"].stringValue)!
                        if code != 200 {
                            self.view.makeToast(myJosn.dictionary!["message"]!.stringValue, duration: 2, position: .Center)
                        }
                        else{
                            jwt.jwtTemp = myJosn.dictionary!["message"]!.stringValue
                            jwt.appUsername = userName
                            jwt.appPwd = password
                            self.view.makeToast("登陆成功", duration: 1, position: .Center)
                            self.performSegueWithIdentifier("login", sender: self)
                        }
                    }
                    break;
                case .Failure(let error):
                    print("\(error)")
                    break;
                }
                
                HUD!.removeFromSuperview()
            })
            }) { () -> Void in
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if jwt.appUsername.length > 0 && jwt.appPwd.length > 0 {
            username.text = jwt.appUsername
            password.text = jwt.appPwd
            selfLogin(jwt.appUsername, password: jwt.appPwd)
        }
        
    }
    
}
