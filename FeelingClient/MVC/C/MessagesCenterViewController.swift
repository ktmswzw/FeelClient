//
//  MessagesCenterViewController.swift
//  FeelingClient
//
//  Created by Vincent on 16/5/2.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import UIKit
import XLPagerTabStrip

import Foundation

class MessagesCenterViewController: TwitterPagerTabStripViewController {
    
    var isReload = false
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let child_1 = MessagesSendTableTableViewController(style: .Plain, itemInfo: "寄出")
        let child_2 = MessagesGetTableViewController(style: .Plain, itemInfo: "解开")
        guard isReload else {
            return [child_1, child_2]
        }
        
        var childViewControllers = [child_1, child_2]
        
        for (index, _) in childViewControllers.enumerate(){
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index{
                swap(&childViewControllers[index], &childViewControllers[n])
            }
        }
        return childViewControllers
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
