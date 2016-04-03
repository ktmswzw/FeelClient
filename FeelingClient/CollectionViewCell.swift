//
//  CollectionViewCell.swift
//  FeelingClient
//
//  Created by Vincent on 16/4/3.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import Foundation
import Haneke

class CollectionViewCell: UICollectionViewCell {
    
    var imageView : UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initHelper()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initHelper()
    }
    
    func initHelper() {
        imageView = UIImageView(frame: self.contentView.bounds)
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.contentView.addSubview(imageView)
    }
    
    override func prepareForReuse() {
        imageView.hnk_cancelSetImage()
        imageView.image = nil
    }
    
}