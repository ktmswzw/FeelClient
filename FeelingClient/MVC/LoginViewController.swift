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
import SwiftyDB

class LoginViewController: DesignableViewController,UITextFieldDelegate {
    
    
    @IBOutlet var username: AnimatableTextField!
    @IBOutlet var password: AnimatableTextField!
    
    var actionButton: ActionButton!
    let database = SwiftyDB(databaseName: "UserInfo")
    var viewModel:LoginUserInfoViewModel!
    
    var userinfo: UserInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "lonely-children")
        let blurredImage = image!.imageByApplyingBlurWithRadius(3)
        self.view.layer.contents = blurredImage.CGImage
        
        let register = ActionButtonItem(title: "注册帐号", image: UIImage(named: "new")!)
        register.action = { item in
            self.performSegueWithIdentifier("register", sender: self)
        }
        let forget = ActionButtonItem(title: "忘记密码", image: UIImage(named: "new")!)
        forget.action = { item in }
        
        actionButton = ActionButton(attachedToView: self.view, items: [register])
        actionButton.action = { button in button.toggleMenu() }
        actionButton.setImage(UIImage(named: "new"), forState: .Normal)
        actionButton.backgroundColor = UIColor.lightGrayColor()
        
        username.delegate = self
        password.delegate = self
        
        viewModel = LoginUserInfoViewModel(delegate: self)
        
        
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
                
                viewModel.userName = userNameText!
                viewModel.password = passwordText!
                loginDelegate()
            }
            
        }
        else
        {
            self.view.makeToast("帐号或密码为空", duration: 2, position: .Center)
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if jwt.appUsername.length > 0 && jwt.appPwd.length > 0 {
            username.text = jwt.appUsername
            //            password.text = jwt.appPwd
            viewModel.userName = jwt.appUsername
            viewModel.password = jwt.appPwd
            loginDelegate()
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if jwt.appUsername.length == 0 {
            //            username.text = ""
            password.text = ""
        }
        
    }
    
    
    
}

extension LoginViewController: LoginUserModelDelegate {
    func loginDelegate(){
        HUD!.showAnimated(true, whileExecutingBlock: { () -> Void in
            self.viewModel.loginDelegate({ (r:BaseApi.Result) in
                switch (r) {
                case .Success(let r):
                    if let userInfo = r as? UserInfo {
                        self.userinfo = userInfo
                        jwt.jwtTemp = userInfo.JWTToken
                        jwt.imToken = userInfo.IMToken
                        jwt.appUsername = self.viewModel.userName
                        jwt.appPwd = self.viewModel.password
                        self.database.addObject(userInfo, update: true)
                                                
                        self.view.makeToast("登陆成功", duration: 1, position: .Center)
                        self.performSegueWithIdentifier("login", sender: self)
                    }
                    if jwt.imToken.length != 0 {
                        RCIM.sharedRCIM().connectWithToken(jwt.imToken,
                            success: { (userId) -> Void in
                                print("登陆成功。当前登录的用户ID：\(userId)")
                                
                                
                                //设置当前登陆用户的信息
                                RCIM.sharedRCIM().currentUserInfo = RCUserInfo.init(userId: userId, name: self.userinfo.nickname, portrait: self.userinfo.avatar)
                                
                                
                                
                            }, error: { (status) -> Void in
                                print("登陆的错误码为:\(status.rawValue)")
                            }, tokenIncorrect: {
                                //token过期或者不正确。
                                //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
                                //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
                                print("token错误")
                        })
                    }
                    break;
                case .Failure(let msg):
                    print("\(msg)")
                    break;
                }
                
            })
            HUD!.removeFromSuperview()
        }) { () -> Void in
        }
        
    }
    func getToken(){
    }
}

