//
//  MessagesCenterViewController.swift
//  FeelingClient
//
//  Created by Vincent on 16/5/2.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import UIKit
import PageMenu

class MessagesCenterViewController: UIViewController {
    
    var pageMenu : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "来往的信件"
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Compact)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Default
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        self.navigationController?.navigationBar.hidden = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0 )]
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<-", style: UIBarButtonItemStyle.Done, target: self, action: #selector(MessagesCenterViewController.didTapGoToLeft))
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "->", style: UIBarButtonItemStyle.Done, target: self, action: #selector(MessagesCenterViewController.didTapGoToRight))
        
        // MARK: - Scroll menu setup
        
        // Initialize view controllers to display and place in array
        var controllerArray : [UIViewController] = []
        
        let controller1 : MessagesSendTableTableViewController = MessagesSendTableTableViewController(nibName: "MessagesSendTableTableViewController", bundle: nil)
        controller1.title = "收到"
        controllerArray.append(controller1)
        let controller2 : MessagesGetTableViewController = MessagesGetTableViewController(nibName: "MessagesGetTableViewController", bundle: nil)
        controller2.title = "发出"
        controllerArray.append(controller2)
        
        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)),
            .ViewBackgroundColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)),
            .SelectionIndicatorColor(UIColor.orangeColor()),
            .BottomMenuHairlineColor(UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)),
            .MenuItemFont(UIFont(name: "Helvetica-Bold", size: 10.0)!),
            .MenuHeight(25.0),
            .MenuItemWidth(100),
            .CenterMenuItems(true)
            
        ]
        
        // 系统中能够支持的字体名称
//        let arrFont = UIFont.familyNames()
//        print(arrFont)
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        self.addChildViewController(pageMenu!)
        self.view.addSubview(pageMenu!.view)
        
        pageMenu!.didMoveToParentViewController(self)
    }
    
    func didTapGoToLeft() {
        let currentIndex = pageMenu!.currentPageIndex
        
        if currentIndex > 0 {
            pageMenu!.moveToPage(currentIndex - 1)
        }
    }
    
    func didTapGoToRight() {
        let currentIndex = pageMenu!.currentPageIndex
        
        if currentIndex < pageMenu!.controllerArray.count {
            pageMenu!.moveToPage(currentIndex + 1)
        }
    }
    
    // MARK: - Container View Controller
    override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
        return true
    }
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
