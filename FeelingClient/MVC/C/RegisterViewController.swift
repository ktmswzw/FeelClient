//
//  RegisterViewController.swift
//  FeelingClient
//
//  Created by vincent on 17/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//
import UIKit
import IBAnimatable
import SwiftyJSON
import Alamofire
import SwiftyDB

class RegisterViewController: DesignableViewController,UITextFieldDelegate{
    @IBOutlet var username: AnimatableTextField!
    @IBOutlet var getCodesButton: AnimatableButton!
    
    @IBOutlet var codes: AnimatableTextField!
    @IBOutlet var verifyCodesButton: AnimatableButton!
    @IBOutlet var password: AnimatableTextField!
    @IBOutlet var registerButton: AnimatableButton!
    
    var viewModel:LoginUserInfoViewModel!
    
    var realPhone: String = ""
    
    let database = SwiftyDB(databaseName: "UserInfo")
    var userinfo: UserInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "lonely-children")
        let blurredImage = image!.imageByApplyingBlurWithRadius(10)
        self.view.layer.contents = blurredImage.CGImage
        
        viewModel = LoginUserInfoViewModel(delegate: self)
        self.getCodesButton.disable()
        self.verifyCodesButton.disable()
        self.registerButton.disable()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func getCodes(sender: AnyObject) {
        if self.username.validatePhoneNumber(){
            SMSSDK.getVerificationCodeByMethod(SMSGetCodeMethodSMS, phoneNumber: username.text, zone: "86", customIdentifier: nil) { (error : NSError!) -> Void in
                
                if (error == nil)
                {
                    self.view.makeToast("请求成功,请等待短信～", duration: 1, position: .Center)
                }
                else
                {
                    // 错误码可以参考‘SMS_SDK.framework / SMSSDKResultHanderDef.h’
                    self.view.makeToast("请求失败", duration: 1, position: .Center)
                }
            }
        }
        else{
            self.view.makeToast("给个手机号，11位，中国造", duration: 1, position: .Center)
        }
    }
    
    @IBAction func verify(sender: UIButton) {
        SMSSDK.commitVerificationCode(codes.text, phoneNumber: username.text, zone: "86") { (error : NSError!) -> Void in
            if(error == nil){
                self.view.makeToast("验证成功", duration: 1, position: .Center)
                self.username.enabled = false
                self.realPhone = self.username.text!
            }else{
                self.view.makeToast("验证失败", duration: 1, position: .Center)
            }
        }
    }
    
    @IBAction func register(sender: AnyObject) {
        
        if username.text != "" && password.text != ""
        {
            if self.realPhone != self.username.text! {
                self.view.makeToast("手机号已更换，请修改", duration: 2, position: .Center)
                return
            }
            if !self.password.validatePassword() {
                self.view.makeToast("密码必选大于6位数小于18的数字或字符", duration: 2, position: .Center)
            }
            else {
                self.viewModel.userName = self.realPhone
                self.viewModel.password = password.text!.md5()!
                registerDelegate()
            }
            
        }
        else
        {
            //self.alertStatusBarMsg("帐号或密码为空");
            self.view.makeToast("帐号或密码为空", duration: 2, position: .Center)
        }
    }
    
    @IBAction func closeBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editingCodesChanged(sender: AnyObject) {
        if username.notEmpty {
            self.getCodesButton.enable()
        } else {
            self.getCodesButton.disable()
        }
    }
    @IBAction func editingVerifyChanged(sender: AnyObject) {
        if codes.notEmpty {
            self.verifyCodesButton.enable()
        } else {
            self.verifyCodesButton.disable()
        }
    }
    @IBAction func editingRegisterChanged(sender: AnyObject) {
        if password.notEmpty && realPhone.length != 0 {
            self.registerButton.enable()
        } else {
            self.registerButton.disable()
        }
    }
    
}

    extension RegisterViewController: LoginUserModelDelegate {
        func registerDelegate(){
            self.view.makeToastActivity(.Center)
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
                        self.view.makeToast("注册成功", duration: 1, position: .Center)
                        
                        self.performSegueWithIdentifier("registerIn", sender: self)
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
    }
