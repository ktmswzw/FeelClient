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
import ImagePickerSheetController
import Eureka

var imageViewSelf = UIImageView(image: UIImage(named: "agirl"))

class SelfViewController: FormViewController {
    
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
        
        var tmp = ""
        
        let list = database.objectsForType(UserInfo.self, matchingFilter: ["id": jwt.userId]).value!
        
        if list.count > 0 {
            userinfo = list[0]
            
            imageViewSelf.hnk_setImageFromURL(NSURL(string:userinfo.avatar)!)
            
            if userinfo.register {
                tmp = userinfo.phone
            }
            
            form = Section() {
                $0.header = HeaderFooterView<EurekaSelfView>(HeaderFooterProvider.Class)
                }
            
                +++ Section()
                <<< PhoneRow("phone"){ $0.title = "手机"
                    $0.disabled = true
                    $0.value = tmp
                }
                <<< TextRow("realname") {
                    $0.title = "姓名"
                    $0.placeholder = "真实姓名"
                }
                <<< TextRow("nickname") {$0.title = "昵称"
                    $0.value = userinfo.nickname
                    $0.placeholder = "朋友或亲人对你的昵称"
                    }
                <<< ActionSheetRow<String>() {
                    $0.title = "性别"
                    $0.options = ["女", "男", "无"]
                    $0.value = getSex(userinfo.sex)
                    
                }.onChange { row in
                    self.sexChange(row.value!)
                }
                
                <<< TextRow("mommo") {$0.title = "签名"
                $0.value = userinfo.motto
                }
                
                +++ Section("版本1.0")
                <<< ButtonRow() { (row: ButtonRow) -> Void in
                    row.title = "退出"
                    }  .onCellSelection({ (cell, row) in
                        self.exitAppAction()
                    })

            
            self.viewModel.sex = userinfo.sex
        }
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SelfViewController.presentImagePickerSheet))
        imageViewSelf.userInteractionEnabled = true
        imageViewSelf.addGestureRecognizer(tapGestureRecognizer)
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
        if let motto = form.rowByTag("motto")?.baseValue as? String {
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
                
                break;
            case .Failure(let msg):
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.navigationController?.view.hideToastActivity()
                self.view.makeToast("保存失败\(msg)", duration: 2, position: .Center)
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
        let presentImagePickerController: UIImagePickerControllerSourceType -> () = { source in
            let controller = UIImagePickerController()
            controller.delegate = self
            var sourceType = source
            if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                sourceType = .PhotoLibrary
                print("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
            }
            controller.sourceType = sourceType
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
        let controller = ImagePickerSheetController(mediaType: .ImageAndVideo)
        controller.addAction(ImagePickerAction(title: NSLocalizedString("拍摄", comment: "标题"),handler: { _ in
            presentImagePickerController(.Camera)
            }, secondaryHandler: { _, numberOfPhotos in
                for ass in controller.selectedImageAssets
                {
                    let image = getImageFromPHAsset(ass)
                    imageViewSelf.image = image
                    self.images.append(image)
                    
                }
        }))
        controller.addAction(ImagePickerAction(title: NSLocalizedString("相册", comment: "标题"), secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "Action Title"), $0) as String}, handler: { _ in
            presentImagePickerController(.PhotoLibrary)
            }, secondaryHandler: { _, numberOfPhotos in
                //print("Send \(controller.selectedImageAssets)")
                for ass in controller.selectedImageAssets
                {
                    let image = getImageFromPHAsset(ass)
                    imageViewSelf.image = image
                    self.images.removeAll()
                    self.images.append(image)
                }
                
        }))
        controller.addAction(ImagePickerAction(title: NSLocalizedString("取消", comment: "Action Title"), style: .Cancel, handler: { _ in
            //print("Cancelled")
        }))
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            controller.modalPresentationStyle = .Popover
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.sourceRect = CGRect(origin: view.center, size: CGSize())
        }
        
        presentViewController(controller, animated: true, completion: nil)
    }
}


extension SelfViewController: UserInfoModelDelegate{
    
}

extension SelfViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageViewSelf.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
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