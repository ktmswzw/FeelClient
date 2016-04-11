//
//  HUDUtil.swift
//  FeelingClient
//
//  Created by Vincent on 4/11/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation

import MBProgressHUD

public class HUDUtil{
    
    public static func initHUD(view:UIView,title: String ) {
        let HUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        HUD?.mode = MBProgressHUDMode.AnnularDeterminate;
        HUD.minSize = CGSizeMake(150, 100);
        HUD.labelText = title;
    }
    
}

