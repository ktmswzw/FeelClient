//
//  UICircleImage.swift
//  iKECIN
//
//  Created by apple on 15/10/15.
//
//

import UIKit

@IBDesignable class UICircleImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    /*这个函数渲染的效果可以显示在IB中*/
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
        self.contentMode = UIViewContentMode.Center
    }
}
