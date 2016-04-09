//
//  SelfViewController.swift
//  FeelingClient
//
//  Created by vincent on 16/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import IBAnimatable
import UIKit
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif
import SwiftyDB
class SelfViewController: DesignableViewController {
    
    @IBOutlet weak var exitApp: UIButton!
    var disposeBag = DisposeBag()
    
    
    @IBOutlet weak var imageView: AnimatableImageView!
    @IBOutlet weak var name: AnimatableTextField!
    @IBOutlet weak var motto: AnimatableTextField!
    @IBOutlet weak var adress: AnimatableTextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "horse")//lonely-children
        let blurredImage = image!.imageByApplyingBlurWithRadius(30)
        self.view.layer.contents = blurredImage.CGImage
        // Do any additional setup after loading the view.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SelfViewController.save))
        
        
        let database = SwiftyDB(databaseName: "UserInfo")
        
        let list = database.objectsForType(UserInfo.self, matchingFilter: ["id": jwt.userId]).value!
        
        if list.count > 0 {
            let userinfo = list[0]
            
            self.imageView.hnk_setImageFromURL(NSURL(string:userinfo.avatar)!)
            self.name.text = userinfo.nickname
            self.motto.text = userinfo.phone
            self.adress.text = userinfo.region
        }
        
        exitApp.rx_tap
            .subscribeNext { [weak self] in self?.exitAppAction() }
            .addDisposableTo(disposeBag)
        
        
    }
    
    func save()
    {
        
        self.view.makeToast("error", duration: 1, position: .Center)
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
            //navigationController!.popToRootViewControllerAnimated(false)
        })
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
