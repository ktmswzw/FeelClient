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
import Whisper


func getAssetThumbnail(asset: PHAsset) -> UIImage {
    let manager = PHImageManager.defaultManager()
    let option = PHImageRequestOptions()
    var thumbnail = UIImage()
    option.synchronous = true
    manager.requestImageForAsset(asset, targetSize: CGSize(width: 50.0, height: 50.0), contentMode: .AspectFit, options: option, resultHandler: {(result, info)->Void in
        thumbnail = result!
    })
    return thumbnail
}

func imageResize (image:UIImage, sizeChange:CGSize)-> UIImage{
    
    let hasAlpha = true
    let scale: CGFloat = 0.0 // Use scale factor of main screen
    
    UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
    image.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
    
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    return scaledImage
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

extension UIViewController:MBProgressHUDDelegate {
    
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
    
    
    // MARK: - MBProgressHUDDelegate
    func hudWasHidden(hud: MBProgressHUD) {
        HUD!.removeFromSuperview()
        HUD = nil
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

