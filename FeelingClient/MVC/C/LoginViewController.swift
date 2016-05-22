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
import VideoSplashKit
class LoginViewController: VideoSplashViewController,UITextFieldDelegate {
    
    
    @IBOutlet var username: AnimatableTextField!
    @IBOutlet var password: AnimatableTextField!
    
    var actionButton: ActionButton!
    let database = SwiftyDB(databaseName: "UserInfo")
    var viewModel:LoginUserInfoViewModel!
    let url = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("0900", ofType: "mp4")!)
    
    @IBOutlet weak var loginBtn: AnimatableButton!
    var userinfo: UserInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.videoFrame = view.frame
        self.fillMode = .ResizeAspectFill
        self.alwaysRepeat = false
        self.sound = false
        self.startTime = 0.5
        self.duration = 17.0
        self.alpha = 0.7
        self.backgroundColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0 )
        
        self.contentURL = url
        self.restartForeground = true
        
                
        let lookAnyWhere = ActionButtonItem(title: "随便看看", image: UIImage(named: "address")!)
        lookAnyWhere.action = { item in
            self.registerDervice()
        }
        let register = ActionButtonItem(title: "注册帐号", image: UIImage(named: "self")!)
        register.action = { item in
            self.performSegueWithIdentifier("register", sender: self)
        }
        let forget = ActionButtonItem(title: "忘记密码", image: UIImage(named: "readfire")!)
        forget.action = { item in
            self.view.makeToast("老板没给发薪，程序员罢工了", duration: 1, position: .Center)
        }
        
        actionButton = ActionButton(attachedToView: self.view, items: [register,lookAnyWhere,forget])
        actionButton.action = { button in button.toggleMenu() }
        actionButton.setImage(UIImage(named: "new"), forState: .Normal)
        actionButton.backgroundColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 0 )
        
        
        
        username.delegate = self
        password.delegate = self
        
        viewModel = LoginUserInfoViewModel(delegate: self)
        
    }
    
    func registerDervice()
    {
        self.view.makeToastActivity(.Center)
        
        let uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString
        self.viewModel.userName = uuid
        let password = "123456"
        self.viewModel.password = password.md5()!
        
        self.viewModel.register({ (r:BaseApi.Result) in
            switch (r) {
            case .Success(let r):
                if let userInfo = r as? UserInfo {
                    self.userinfo = userInfo
                    jwt.jwtTemp = userInfo.JWTToken
                    jwt.imToken = userInfo.IMToken
                    jwt.appUsername = self.viewModel.userName
                    jwt.appPwd = self.viewModel.password
                    jwt.userId = userInfo.id
                    jwt.userName = userInfo.nickname
                    self.database.addObject(userInfo, update: true)
                    self.view.hideToastActivity()
                    self.view.makeToast("默认注册成功，密码123456", duration: 3, position: .Center)
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    //self.performSegueWithIdentifier("login", sender: self)
                }
                if jwt.imToken.length != 0 {
                    RCIM.sharedRCIM().connectWithToken(jwt.imToken,
                        success: { (userId) -> Void in
                            //设置当前登陆用户的信息
                            RCIM.sharedRCIM().currentUserInfo = RCUserInfo.init(userId: userId, name: self.userinfo.nickname, portrait: self.userinfo.avatar)
                        }, error: { (status) -> Void in
                            self.view.hideToastActivity()
                        }, tokenIncorrect: {
                            print("token错误")
                    })
                }
                loader = PhotoUpLoader.init()//初始化图片上传
                break;
            case .Failure(let msg):
                print("\(msg)")
                
                self.view.hideToastActivity()
                self.view.makeToast("服务器离家出走", duration: 1, position: .Center)
                
                break;
            }
        })

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
                self.loginBtn.enabled = false
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
            self.loginBtn.enabled = false
            loginDelegate()
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if jwt.appUsername.length == 0 {
            //            username.text = ""
            password.text = ""
            self.loginBtn.enabled = true
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}

extension LoginViewController: LoginUserModelDelegate {
    func loginDelegate(){
        self.view.makeToastActivity(.Center)
            self.viewModel.loginDelegate({ (r:BaseApi.Result) in
                switch (r) {
                case .Success(let r):
                    if let userInfo = r as? UserInfo {
                        self.userinfo = userInfo
                        jwt.jwtTemp = userInfo.JWTToken
                        jwt.imToken = userInfo.IMToken
                        jwt.appUsername = self.viewModel.userName
                        jwt.appPwd = self.viewModel.password
                        jwt.userId = userInfo.id
                        jwt.userName = userInfo.nickname
                        self.database.asyncAddObject(self.userinfo) { (result) -> Void in
                            if let error = result.error {
                                self.view.makeToast("保存失败\(error)", duration: 2, position: .Center)
                            }
                        }
                        
                        self.view.hideToastActivity()
                        self.view.makeToast("登陆成功", duration: 1, position: .Center)
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                        //self.performSegueWithIdentifier("login", sender: self)
                    }
                    if jwt.imToken.length != 0 {
                        RCIM.sharedRCIM().connectWithToken(jwt.imToken,
                            success: { (userId) -> Void in
                                //设置当前登陆用户的信息
                                RCIM.sharedRCIM().currentUserInfo = RCUserInfo.init(userId: userId, name: self.userinfo.nickname, portrait: self.userinfo.avatar)
                                
                                
                                
                            }, error: { (status) -> Void in
                                self.view.hideToastActivity()
                            }, tokenIncorrect: {
                                print("token错误")
                        })
                    }
                    loader = PhotoUpLoader.init()//初始化图片上传
                    self.loginBtn.enabled = true
                    break;
                case .Failure(let message):
                    self.view.hideToastActivity()
                    self.view.makeToast("\(message!)", duration: 1, position: .Center)
                    
                    self.loginBtn.enabled = true
                    break;
                }
            })
    }
}

