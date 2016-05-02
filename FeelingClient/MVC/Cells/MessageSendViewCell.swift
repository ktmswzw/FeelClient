//
//  MessageSendViewCell.swift
//  FeelingClient
//
//  Created by Vincent on 16/5/2.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import UIKit
import IBAnimatable

class MessageSendViewCell: UITableViewCell {

    @IBOutlet var imagesMe: AnimatableImageView!
    @IBOutlet var question: UILabel!
    @IBOutlet var tryCount: UILabel!
    @IBOutlet var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
