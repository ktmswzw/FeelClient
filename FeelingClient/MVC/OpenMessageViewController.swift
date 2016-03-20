//
//  OpenMessageViewController.swift
//  FeelingClient
//
//  Created by vincent on 20/3/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit
import IBAnimatable
import SwiftyJSON
import Alamofire

class OpenMessageViewController: DesignableViewController,UITextFieldDelegate {
    
    var viewModel: MessageViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        let image = UIImage(named: "lonely-children")//lonely-children
        let blurredImage = image!.imageByApplyingBlurWithRadius(15)
        self.view.layer.contents = blurredImage.CGImage
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
