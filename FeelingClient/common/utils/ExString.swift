//
//  ExString.swift
//  AudioRecorder
//
//  Created by Vincent on 16/5/22.
//  Copyright © 2016年 com.xecoder.test. All rights reserved.
//


import UIKit

extension UIColor {
    
    convenience init?(hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }
    
    
    convenience init?(hexString: String, alpha: Float) {
        var hex = hexString
        
        if hex.hasPrefix("#") {
            hex = hex.substringFromIndex(hex.startIndex.advancedBy(1))
        }
        
        if let _ = hex.rangeOfString("(^[0-9A-Fa-f]{6}$)|(^[0-9A-Fa-f]{3}$)", options: .RegularExpressionSearch) {
            if hex.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 3 {
                let redHex = hex.substringToIndex(hex.startIndex.advancedBy(1))
                let greenHex = hex.substringWithRange(hex.startIndex.advancedBy(1)..<hex.startIndex.advancedBy(2))
                let blueHex = hex.substringFromIndex(hex.startIndex.advancedBy(2))
                hex = redHex + redHex + greenHex + greenHex + blueHex + blueHex
            }
            let redHex = hex.substringToIndex(hex.startIndex.advancedBy(2))
            let greenHex = hex.substringWithRange(hex.startIndex.advancedBy(2)..<hex.startIndex.advancedBy(4))
            let blueHex = hex.substringWithRange(hex.startIndex.advancedBy(4)..<hex.startIndex.advancedBy(6))
            var redInt:   CUnsignedInt = 0
            var greenInt: CUnsignedInt = 0
            var blueInt:  CUnsignedInt = 0
            
            NSScanner(string: redHex).scanHexInt(&redInt)
            NSScanner(string: greenHex).scanHexInt(&greenInt)
            NSScanner(string: blueHex).scanHexInt(&blueInt)
            
            self.init(red: CGFloat(redInt) / 255.0, green: CGFloat(greenInt) / 255.0, blue: CGFloat(blueInt) / 255.0, alpha: CGFloat(alpha))
        }
        else
        {
            self.init()
            return nil
        }
    }
    
    convenience init?(hex: Int) {
        self.init(hex: hex, alpha: 1.0)
    }
    
    
    convenience init?(hex: Int, alpha: Float) {
        let hexString = NSString(format: "%2X", hex)
        self.init(hexString: hexString as String, alpha: alpha)
    }
}


extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        
        let rect = CGRectMake(0, 0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    func resizeImage() -> UIImage {
        return self.stretchableImageWithLeftCapWidth(Int(self.size.width / CGFloat(2)), topCapHeight: Int(self.size.height / CGFloat(2)))
    }
}

extension UIButton {
    func addAnimation(durationTime: Double) {
        let groupAnimation = CAAnimationGroup()
        groupAnimation.removedOnCompletion = true
        
        let animationZoomOut = CABasicAnimation(keyPath: "transform.scale")
        animationZoomOut.fromValue = 0
        animationZoomOut.toValue = 1.2
        animationZoomOut.duration = 3/4 * durationTime
        
        let animationZoomIn = CABasicAnimation(keyPath: "transform.scale")
        animationZoomIn.fromValue = 1.2
        animationZoomIn.toValue = 1.0
        animationZoomIn.beginTime = 3/4 * durationTime
        animationZoomIn.duration = 1/4 * durationTime
        
        groupAnimation.animations = [animationZoomOut, animationZoomIn]
        self.layer.addAnimation(groupAnimation, forKey: "addAnimation")
    }
}


extension NSString {
    func stringWidthFont(font: UIFont) -> CGFloat {
        if self.length < 1 {
            return 0.0
        }
        
        let size = self.boundingRectWithSize(CGSizeMake(200, 1000), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return size.width ?? 0.0
    }
}


extension UIButton {
    class func createButton(title: String, backGroundColor: UIColor) -> UIButton {
        let button = UIButton(type: UIButtonType.Custom)
        button.setTitle(title, forState: .Normal)
        button.backgroundColor = backGroundColor
        button.setBackgroundImage(UIImage.imageWithColor(backGroundColor), forState: .Normal)
        return button
    }
}

