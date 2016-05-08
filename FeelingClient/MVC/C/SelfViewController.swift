//
//  SelfViewController.swift
//  FeelingClient
//
//  Created by vincent on 16/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import IBAnimatable
import UIKit
import SwiftyDB
import MobileCoreServices
import MediaPlayer
import ImagePickerSheetController

class SelfViewController: DesignableViewController {
    
    var viewModel: UserInfoViewModel!    
    @IBOutlet weak var imageView: AnimatableImageView!
    @IBOutlet weak var name: AnimatableTextField!
    @IBOutlet weak var username: AnimatableTextField!
    @IBOutlet weak var motto: AnimatableTextField!
    @IBOutlet weak var segment: UISegmentedControl!
    
    var picker = UIImagePickerController()
    
    var images = [UIImage]()
    
    let database = SwiftyDB(databaseName: "UserInfo")
    
    var userinfo = UserInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置"
        let image = UIImage(named: "lonely-children")
        let blurredImage = image!.imageByApplyingBlurWithRadius(30)
        self.view.layer.contents = blurredImage.CGImage
        // Do any additional setup after loading the view.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SelfViewController.saveImage))
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SelfViewController.exitAppAction))
        
        
        viewModel = UserInfoViewModel(delegate: self)
        
        
        let list = database.objectsForType(UserInfo.self, matchingFilter: ["id": jwt.userId]).value!
        
        if list.count > 0 {
            userinfo = list[0]
            
            self.imageView.hnk_setImageFromURL(NSURL(string:userinfo.avatar)!)
            self.name.text = userinfo.nickname
            self.motto.text = userinfo.motto
            if userinfo.register {
                self.username.text = userinfo.phone
            }
            self.segment.selectedSegmentIndex = getSex(userinfo.sex)
            self.viewModel.sex = userinfo.sex
        }
        
        //点击
        //        exitApp.rx_tap
        //            .subscribeNext { [weak self] in self?.exitAppAction() }
        //            .addDisposableTo(disposeBag)
        
        //照片
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(SelfViewController.presentImagePickerSheet))
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    
    func getSex(name:String) -> Int {
        if name=="MALE" {
            return 0
        }
        if name=="FEMALE"{
            return 1
        }
        else {
            return 2
        }
    }
    
    @IBAction func sexChange(sender: AnyObject) {
        switch segment.selectedSegmentIndex
        {
        case 0:
            self.viewModel.sex = "MALE";
        case 1:
            self.viewModel.sex = "FEMALE";
        case 2:
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
        viewModel.nickname = self.name.text!
        viewModel.motto = self.motto.text!
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
        database.deleteObjectsForType(UserInfo.self)
        //断开连接并设置不再接收推送消息
        RCIM.sharedRCIM().disconnect(false)
        
        //let navigationController:UINavigationController? = self.tabBarController?.presentingViewController as? UINavigationController
//        self.dismissViewControllerAnimated(true, completion: { () -> Void in
//            self.view.makeToast("退出成功", duration: 2, position: .Center)
//        })
        self.view.makeToast("退出成功", duration: 2, position: .Center)
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
                    self.imageView.image = image
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
                    self.imageView.image = image
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
        self.imageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}