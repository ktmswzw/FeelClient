//
//  ImageUtils.swift
//  feeling
//
//  Created by vincent on 15/12/29.
//  Copyright © 2015年 xecoder. All rights reserved.
//

import Foundation
import Photos
import UIKit
import ObjectMapper
//import AlamofireImage

func getImageFromPHAsset(asset: PHAsset) -> UIImage {
    let manager = PHImageManager.defaultManager()
    let option = PHImageRequestOptions()
    var thumbnail = UIImage()
    option.synchronous = true
    manager.requestImageForAsset(asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .AspectFit, options: option, resultHandler: {(result, info)->Void in
        thumbnail = result!
    })
    return thumbnail
}

func getAssetThumbnail(asset: PHAsset) -> UIImage {
    let manager = PHImageManager.defaultManager()
    let option = PHImageRequestOptions()
    var thumbnail = UIImage()
    option.synchronous = true
    manager.requestImageForAsset(asset, targetSize: CGSize(width: 50, height: 50), contentMode: .AspectFit, options: option, resultHandler: {(result, info)->Void in
        thumbnail = result!
    })
    return thumbnail
}

func getPin(one: UIImage,two: UIImage) -> UIImage {
    let myImage = imageResize(one, sizeChange: CGSize(width: 40.0, height: 40.0))
    let backgrounpImage = imageResize(two, sizeChange: CGSize(width: 40.0, height: 49))
    
    let frontImage =  Toucan(image: myImage).maskWithEllipse(borderWidth: 1, borderColor: UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0 )).image
    
    //        let frontImage = myImage.af_imageRoundedIntoCircle();
    let newImage = mergeImages(backgrounpImage ,backgroundImage: frontImage )
    return newImage
}


func imageResize (image:UIImage, sizeChange:CGSize)-> UIImage{
    UIGraphicsBeginImageContextWithOptions(sizeChange, false, 0.0)
    image.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
    
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    return scaledImage
}


func mergeImages (forgroundImage : UIImage, backgroundImage : UIImage) -> UIImage {
    let bottomImage = forgroundImage
    let topImage = backgroundImage
    let size = forgroundImage.size
    let forsize = backgroundImage.size
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    let areaSize = CGRect(x: 0, y: 0, width: size.width , height: size.height )
    bottomImage.drawInRect(areaSize)
    let topSize = CGRect(x: (size.width - forsize.width) / 2  , y: (size.height - forsize.height) / 2 - 5, width: forsize.width , height: forsize.height )
    topImage.drawInRect(topSize)
    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}


let YUN = "http://habit-10005997.image.myqcloud.com";


/**
 * 获取完整路径
 * @return
 */
func getPath(url:String) -> String {
    return "\(YUN)/" + url;
}

/**
 * 获取完整路径small
 * @return
 */
func getPathSmall(url:String) -> String {
    return getPath(url) + "/small";
}


extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil).first as? UIView
    }
}


extension UITextField {
    var notEmpty: Bool{
        get {
            return self.text != ""
        }
    }
    func validate(RegEx: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", RegEx)
        return predicate.evaluateWithObject(self.text)
    }
    func validateEmail() -> Bool {
        return self.validate("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
    }
    func validatePhoneNumber() -> Bool {
        return self.validate("^\\d{11}$")
    }
    func validatePassword() -> Bool {
        return self.validate("^[A-Z0-9a-z]{6,18}")
    }
}

extension UIViewController {
    
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}

extension UIButton {
    func disable() {
        self.enabled = false
        self.alpha = 0.5
    }
    func enable() {
        self.enabled = true
        self.alpha = 1
    }
}

extension UITabBarController {
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        guard selectedViewController != nil else { return .Default }
        return selectedViewController!.preferredStatusBarStyle()
    }
}

extension UINavigationController {
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        if self.presentingViewController != nil {
            // NavigationController的presentingViewController不会为nil时，通常意味着Modal
            return self.presentingViewController!.preferredStatusBarStyle()
        }
        else {
            guard self.topViewController != nil else { return .Default }
            return (self.topViewController!.preferredStatusBarStyle());
        }
    }
}
