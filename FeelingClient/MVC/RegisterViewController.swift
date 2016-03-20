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

class RegisterViewController: DesignableViewController,UITextFieldDelegate{
    @IBOutlet var username: AnimatableTextField!
    @IBOutlet var getCodesButton: AnimatableButton!
    
    @IBOutlet var codes: AnimatableTextField!
    @IBOutlet var verifyCodesButton: AnimatableButton!
    @IBOutlet var password: AnimatableTextField!
    @IBOutlet var registerButton: AnimatableButton!
    
    let jwt = JWTTools()
    
    var realPhone: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "lonely-children")
        let blurredImage = image!.imageByApplyingBlurWithRadius(10)
        self.view.layer.contents = blurredImage.CGImage
        
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
                    self.view.makeToast("请求成功,请等待短信～", duration: 1, position: .Top)
                }
                else
                {
                    // 错误码可以参考‘SMS_SDK.framework / SMSSDKResultHanderDef.h’
                    self.view.makeToast("请求失败", duration: 1, position: .Top)
                }
            }
        }
        else{
            self.view.makeToast("给个手机号，11位，中国造", duration: 1, position: .Top)
        }
    }
    
    @IBAction func verify(sender: UIButton) {
        SMSSDK.commitVerificationCode(codes.text, phoneNumber: username.text, zone: "86") { (error : NSError!) -> Void in
            if(error == nil){
                self.view.makeToast("验证成功", duration: 1, position: .Top)
                self.username.enabled = false
                self.realPhone = self.username.text!
            }else{
                self.view.makeToast("验证失败", duration: 1, position: .Top)
            }
        }
    }
    
    @IBAction func register(sender: AnyObject) {
        
        if username.text != "" && password.text != ""
        {
            if self.realPhone != self.username.text! {
                self.view.makeToast("手机号已更换，请修改", duration: 2, position: .Top)
                return
            }
            if !self.password.validatePassword() {
                self.view.makeToast("密码必选大于6位数小于18的数字或字符", duration: 2, position: .Top)
            }
            else {
                let userNameText = self.realPhone
                let passwordText = password.text!.md5()
                
                NetApi().makeCall(Alamofire.Method.POST,section: "/user/register",headers: [:], params: ["username": userNameText,"password":passwordText!,"device":"APP"], completionHandler: { (result:BaseApi.Result) -> Void in
                    switch (result) {
                    case .Success(let r):
                        if let json = r {
                            let myJosn = JSON(json)
                            let code:Int = Int(myJosn["status"].stringValue)!
                            if code != 200 {
                                self.view.makeToast(myJosn.dictionary!["message"]!.stringValue, duration: 2, position: .Top)
                            }
                            else{
                                self.jwt.token = myJosn.dictionary!["message"]!.stringValue
                                self.view.makeToast("登陆成功", duration: 1, position: .Top)
                                self.performSegueWithIdentifier("registerIn", sender: self)
                            }
                        }
                        break;
                    case .Failure(let error):
                        print("\(error)")
                        break;
                    }
                    
                    
                })
                
            }
            
        }
        else
        {
            //self.alertStatusBarMsg("帐号或密码为空");
            self.view.makeToast("帐号或密码为空", duration: 2, position: .Top)
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