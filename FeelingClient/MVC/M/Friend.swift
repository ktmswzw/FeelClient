//
//  Friend.swift
//  FeelingClient
//
//  Created by Vincent on 4/6/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation
import ObjectMapper


class FriendBean: BaseModel {
    override static func newInstance() -> Mappable {
        return FriendBean();
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        id <- map["id"]
        keyUserId <- map["key_user_id"]
        remark <- map["remark"]
        phone <- map["phone"]
        avatar <- map["avatar"]
        motto <- map["motto"]
        user <- map["user"]
        
    }
    
    var id: String = ""
    
    var keyUserId = ""
    
    var phone = ""
    
    var grouping = "";
    /**
     * 拉黑
     */
    var blacklist = false;
    
    /**
     * 好友
     */
    var user = "";
    
    /**
     * 备注
     */
    var remark = "";
    
    var avatar = "";
    
    var motto = "";
}