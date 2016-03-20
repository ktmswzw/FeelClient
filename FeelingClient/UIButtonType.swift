//
//  UIButtonType.swift
//  feeling
//
//  Created by vincent on 15/12/31.
//  Copyright © 2015年 xecoder. All rights reserved.
//


import UIKit

@IBDesignable class UIButtonTypeView: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let borderAlpha : CGFloat = 0.7
        let cornerRadius : CGFloat = 5.0
        
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.backgroundColor = UIColor.clearColor()
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        self.layer.cornerRadius = cornerRadius
        
    }




}