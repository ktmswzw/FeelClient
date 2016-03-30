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

class SelfViewController: DesignableViewController {

    @IBOutlet weak var exitApp: UIButton!
    var disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "horse")//lonely-children
        let blurredImage = image!.imageByApplyingBlurWithRadius(15)
        self.view.layer.contents = blurredImage.CGImage
        // Do any additional setup after loading the view.
        
        
        
        exitApp.rx_tap
            .subscribeNext { [weak self] in self?.exitAppAction() }
            .addDisposableTo(disposeBag)
        
        
    }
    
    func exitAppAction()
    {
        jwt.jwtTemp = ""
        jwt.appUsername = ""
        jwt.appPwd = ""
        
        //self.performSegueWithIdentifier("logout", sender: self)
        
        navigationController!.pushViewController(storyboard!.instantiateViewControllerWithIdentifier("login") as UIViewController, animated: true)

        
        
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
