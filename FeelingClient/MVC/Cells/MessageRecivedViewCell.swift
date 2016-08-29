//
//  MessageRecivedViewCell.swift
//  FeelingClient
//
//  Created by Vincent on 16/5/2.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import UIKit
import IBAnimatable

class MessageRecivedViewCell: UITableViewCell {

    @IBOutlet var imageMe: AnimatableImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var question: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var isArrivalImg: UIImageView!
    @IBOutlet var date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
