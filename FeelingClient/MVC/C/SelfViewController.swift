//
//  SelfViewController.swift
//  FeelingClient
//
//  Created by vincent on 16/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit
import SwiftyDB
import MobileCoreServices
import MediaPlayer
import Eureka
import ALCameraViewController

var imageViewSelf = UIImageView(image: UIImage(named: "agirl"))

class SelfViewController: FormViewController {
    
    var isUpdateImg = false
    var viewModel: UserInfoViewModel!
    var images = [UIImage]()
    let database = SwiftyDB(databaseName: "UserInfo")
    var userinfo = UserInfo()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置"
        
        TextRow.defaultCellUpdate = { cell, row in cell.textField.textColor = UIColor ( red: 0.0, green: 0.4784, blue: 1.0, alpha: 1.0 ) }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SelfViewController.saveImage))
        
        //        
        //        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SelfViewController.exitAppAction))
        //        
        
        viewModel = UserInfoViewModel(delegate: self)
        
        form = Section() {
            $0.header = HeaderFooterView<EurekaSelfView>(HeaderFooterProvider.Class)
            }
            
            +++ Section()
            <<< PhoneRow("phone"){ $0.title = "手机"
                $0.disabled = true
            }
            //            <<< TextRow("realname") {
            //                $0.title = "姓名"
            //                $0.placeholder = "真实姓名"
            //            }
            <<< TextRow("nickname") {$0.title = "昵称"
                $0.placeholder = "朋友或亲人对你的昵称"
            }
            <<< ActionSheetRow<String>() {
                $0.title = "性别"
                $0.tag = "sex"
                $0.options = ["女", "男", "无"]
                
                }.onChange { row in
                    self.sexChange(row.value!)
            }
            
            <<< TextRow("mommo") {$0.title = "签名"
                
            }
            
            +++ Section("版本1.0")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "退出"
                }  .onCellSelection({ (cell, row) in
                    self.exitAppAction()
                })
        
        
        self.viewModel.sex = userinfo.sex
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SelfViewController.presentImagePickerSheet))
        imageViewSelf.userInteractionEnabled = true
        imageViewSelf.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        if(!isUpdateImg) {
            updateInfo()
        }
    }
    
    func updateInfo() {
        let list = database.objectsForType(UserInfo.self, matchingFilter: ["id": jwt.userId]).value!
        
        if list.count > 0 {
            userinfo = list[0]
            
            imageViewSelf.hnk_setImageFromURL(NSURL(string:userinfo.avatar)!)
            
            if userinfo.register {
                form.rowByTag("phone")?.value = userinfo.phone
                form.rowByTag("phone")?.baseCell.update()
                
                form.rowByTag("sex")?.value = getSex(userinfo.sex)
                form.rowByTag("sex")?.baseCell.update()
                
                form.rowByTag("nickname")?.value = userinfo.nickname
                form.rowByTag("nickname")?.baseCell.update()
                
                form.rowByTag("mommo")?.value = userinfo.motto
                form.rowByTag("mommo")?.baseCell.update()
            }
        }
    }
    
    func sexChange(value: String) {
        switch value
        {
        case "男":
            self.viewModel.sex = "MALE";
        case "女":
            self.viewModel.sex = "FEMALE";
        case "无":
            self.viewModel.sex = "OTHER";
        default:
            break;
        }
    }
    
    func saveImage()
    {
        
        self.navigationController?.view.makeToastActivity(.Center)
        if self.images.count != 0 {
            self.viewModel.saveImages(self.images, completeHander: { (r:BaseApi.Result) in
                switch (r) {
                case .Success(let value):
                    self.viewModel.avatar = value as! String
                    self.save()
                    self.images.removeAll()
                    break;
                case .Failure(let msg):
                    self.view.makeToast("保存失败\(msg)", duration: 2, position: .Center)
                    break;
                }
            })
        }
        else{
            self.save()
        }
    }
    
    func save()
    {
        if let nickname = form.rowByTag("nickname")?.baseValue as? String {
            viewModel.nickname = nickname
        }
        if let motto = form.rowByTag("mommo")?.baseValue as? String {
            viewModel.motto = motto
        }
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        viewModel.saveUser("") { (r:BaseApi.Result) in
            switch (r) {
            case .Success(_):
                self.navigationController?.view.hideToastActivity()
                self.view.makeToast("保存成功", duration: 2, position: .Center)
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.view.endEditing(true)
                self.userinfo.nickname = self.viewModel.nickname
                self.userinfo.motto = self.viewModel.motto
                self.userinfo.avatar = self.viewModel.avatar
                self.database.asyncAddObject(self.userinfo) { (result) -> Void in
                    if let error = result.error {
                        self.view.makeToast("保存失败\(error)", duration: 2, position: .Center)
                    }
                }
                
                RCIM.sharedRCIM().refreshUserInfoCache(RCUserInfo(userId: self.viewModel.user_id, name: self.viewModel.nickname, portrait: self.viewModel.avatar), withUserId: self.viewModel.user_id)
                self.isUpdateImg = false
                break;
            case .Failure(_):
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.navigationController?.view.hideToastActivity()
                self.view.makeToast("保存失败,长时间未使用，请重新登录", duration: 2, position: .Center)
                break;
            }
        }
        
        //self.view.makeToast("error", duration: 1, position: .Center)
    }
    
    func exitAppAction()
    {
        self.tabBarController?.selectedIndex = 0
        
        jwt.jwtTemp = ""
        jwt.appUsername = ""
        jwt.appPwd = ""
        jwt.sign_file = ""
        jwt.sign = ""
        database.deleteObjectsForType(UserInfo.self)
        //断开连接并设置不再接收推送消息
        RCIM.sharedRCIM().disconnect(false)
        
        //let navigationController:UINavigationController? = self.tabBarController?.presentingViewController as? UINavigationController
        //        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        //            self.view.makeToast("退出成功", duration: 2, position: .Center)
        //        })
        self.view.makeToast("退出成功", duration: 2, position: .Center)
        //self.navigationController?.popToRootViewControllerAnimated(true)
        self.performSegueWithIdentifier("login", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    func presentImagePickerSheet() {
        let alert = UIAlertController(title: "头像选择", message: "选择照片或者照相", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        
        let imageAction = UIAlertAction(title: "相册", style: UIAlertActionStyle.Default) { (action) -> Void in
            let libraryViewController = CameraViewController.imagePickerViewController(true) { image, asset in
                if  image != nil {
                    self.isUpdateImg = true
                    imageViewSelf.image = image
                    self.images.removeAll()
                    self.images.append(image!)
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            self.presentViewController(libraryViewController, animated: true, completion: nil)
        }
        
        
        let cameraokAction = UIAlertAction(title: "拍摄", style: UIAlertActionStyle.Default ) { (action) -> Void in
            let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { [weak self] image, asset in
                if  image != nil {
                    self!.isUpdateImg = true
                    imageViewSelf.image = image
                    self!.images.removeAll()
                    self!.images.append(image!)
                }
                self?.dismissViewControllerAnimated(true, completion: nil)
                
            }
            
            self.presentViewController(cameraViewController, animated: true, completion: nil)
        }
        
        
        
        alert.addAction(imageAction)
        alert.addAction(cameraokAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}


extension SelfViewController: UserInfoModelDelegate{
    
}

class EurekaSelfView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageViewSelf.frame = CGRect(x: 0, y: 0, width: 130, height: 130)
        imageViewSelf.autoresizingMask = .FlexibleBottomMargin
        let bounds = UIScreen.mainScreen().bounds
        let width = bounds.size.width
        
        self.frame = CGRect(x: 0, y: 0, width: width, height: 140)
        
        imageViewSelf.center = CGPointMake(self.frame.size.width  / 2, (self.frame.size.height / 2) + 15 )
        
        imageViewSelf.contentMode = .ScaleAspectFit
        imageViewSelf.layer.masksToBounds = true
        imageViewSelf.layer.cornerRadius = 5
        
        
        self.addSubview(imageViewSelf)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}