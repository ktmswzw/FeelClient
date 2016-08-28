//
//  MainViewController.swift
//  FeelingClient
//
//  Created by Vincent on 16/5/8.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import UIKit

import SwiftyDB
class MainViewController: UITabBarController, LoginUserModelDelegate {
    
    var userinfo: UserInfo!
    var viewModel:LoginUserInfoViewModel!
    
    let database = SwiftyDB(databaseName: "UserInfo")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sleep(1)
        viewModel = LoginUserInfoViewModel(delegate: self)
        // Do any additional setup after loading the view.
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        if jwt.jwtTemp.length == 0 {
            super.viewDidAppear(animated)
            if jwt.appUsername.length > 0 && jwt.appPwd.length > 0 {
                viewModel.userName = jwt.appUsername
                viewModel.password = jwt.appPwd
                loginDelegate()
            }
            else
            {
                self.performSegueWithIdentifier("login", sender: self)
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
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
                    jwt.userAvator = userInfo.avatar
                    self.database.asyncAddObject(self.userinfo) { (result) -> Void in
                        if let error = result.error {
                            self.view.makeToast("保存失败\(error)", duration: 2, position: .Center)
                        }
                    }
                    self.view.hideToastActivity()
                }
                loginRIM()
                loader = PhotoUpLoader.init()//初始化图片上传
                if Constant.Devicetoken != "" {
                    self.viewModel.updateDeviceToken(Constant.Devicetoken) {_ in }
                }
                break;
            case .Failure(let message):
                self.view.hideToastActivity()
                self.view.makeToast("\(message!)", duration: 1, position: .Center)
                break;
            }
        })
    }
    
}
