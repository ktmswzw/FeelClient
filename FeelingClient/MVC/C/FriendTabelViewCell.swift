//
//  FriendTabelViewCell.swift
//  FeelingClient
//
//  Created by Vincent on 4/7/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation

class FriendTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var remark: UILabel!
    @IBOutlet weak var motto: UILabel!
    @IBOutlet weak var id: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}