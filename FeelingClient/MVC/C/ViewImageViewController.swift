//
//  ViewImageViewController.swift
//  FeelingClient
//
//  Created by Vincent on 4/9/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit

class ViewImageViewController: UIViewController {
    
    var imageUrl = ""
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.hnk_setImageFromURL(NSURL(string:imageUrl)!)
        
    }
    @IBAction func saveImage(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(ViewImageViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error != nil {
            self.view.makeToast("保存失败", duration: 2, position: .Center)
        } else {
            self.view.makeToast("保存成功", duration: 2, position: .Center)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func goBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
