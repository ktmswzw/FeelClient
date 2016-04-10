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
    @IBOutlet weak var motto: AnimatableTextField!
    @IBOutlet weak var segment: UISegmentedControl!
    
    var picker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "horse")//lonely-children
        let blurredImage = image!.imageByApplyingBlurWithRadius(30)
        self.view.layer.contents = blurredImage.CGImage
        // Do any additional setup after loading the view.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SelfViewController.save))
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SelfViewController.exitAppAction))
        
        
        viewModel = UserInfoViewModel(delegate: self)
        
        let database = SwiftyDB(databaseName: "UserInfo")
        
        let list = database.objectsForType(UserInfo.self, matchingFilter: ["id": jwt.userId]).value!
        
        if list.count > 0 {
            let userinfo = list[0]
            
            self.imageView.hnk_setImageFromURL(NSURL(string:userinfo.avatar)!)
            self.name.text = userinfo.nickname
            self.motto.text = userinfo.phone
            self.segment.selectedSegmentIndex = getSex(userinfo.sex)
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
    
    func save()
    {
        viewModel.avatar = ""
        viewModel.nickname = self.name.text!
        viewModel.motto = self.motto.text!
        viewModel.saveUser("") { (r:BaseApi.Result) in
            
        }
        //self.view.makeToast("error", duration: 1, position: .Center)
    }
    
    func exitAppAction()
    {
        jwt.jwtTemp = ""
        jwt.appUsername = ""
        jwt.appPwd = ""
        
        
        
        //断开连接并设置不再接收推送消息
        RCIM.sharedRCIM().disconnect(false)
        
        
        //let navigationController:UINavigationController? = self.tabBarController?.presentingViewController as? UINavigationController
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.view.makeToast("退出成功", duration: 2, position: .Center)
        })
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
                    let image = getAssetThumbnail(ass)
                    self.imageView.image = image
                    
                    self.view.makeToast("更新成功", duration: 1, position: .Center)
                }
        }))
        controller.addAction(ImagePickerAction(title: NSLocalizedString("相册", comment: "标题"), secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "Action Title"), $0) as String}, handler: { _ in
            presentImagePickerController(.PhotoLibrary)
            }, secondaryHandler: { _, numberOfPhotos in
                //print("Send \(controller.selectedImageAssets)")
                for ass in controller.selectedImageAssets
                {
                    let image = getAssetThumbnail(ass)
                    self.imageView.image = image
                    self.view.makeToast("更新成功", duration: 1, position: .Center)
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