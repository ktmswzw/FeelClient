//
//  MessagesGetTableViewController.swift
//  FeelingClient
//
//  Created by Vincent on 16/5/2.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import UIKit

import IBAnimatable

import MapKit
import Foundation
import XLPagerTabStrip

class MessagesGetTableViewController: UITableViewController,MessageViewModelDelegate,IndicatorInfoProvider {
    
    let msg: Messages = Messages.defaultMessages
    
    var msgs = [MessageBean]()
    var itemInfo = IndicatorInfo(title: "View")
    
    init(style: UITableViewStyle, itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        //设置背景颜色
        refreshControl!.backgroundColor = UIColor ( red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0 )
        //设置菊花转的颜色
        refreshControl!.tintColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0 )
        
        //往tableView添加刷新控件
        self.tableView.addSubview(refreshControl!)
        
        self.tableView.registerNib(UINib(nibName: "MessageRecived", bundle: nil), forCellReuseIdentifier: "MessageRecivedViewCell")
        getMessages()
    }
    
    func getMessages()
    {
        self.navigationController?.view.makeToastActivity(.Center)
        self.msg.querySendAndRecived(false, page: 1, size: 1000, completeHander: { (r: BaseApi.Result) in
            switch (r) {
            case .Success(let value):
                if self.msgs.count != 0 {
                    self.msgs.removeAll()
                }
                self.msgs =  value as! [MessageBean]
                self.tableView.reloadData()
                self.navigationController?.view.hideToastActivity()
                break;
            case .Failure(let msg):
                self.view.makeToast("\(msg)", duration: 2, position: .Center)
                self.navigationController?.view.hideToastActivity()
                break;
            }
        })
    }
    
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if refreshControl!.refreshing {
            getMessages()
            refreshControl!.endRefreshing()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return msgs.count
    }
    
    var coordinate = CLLocationCoordinate2D()
    var original_coordinate = CLLocationCoordinate2D()
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if msgs.count > 0 {
            let bean = msgs[indexPath.row] as MessageBean
            //            let nib = MessageInfoGetViewController()//需要跳转的viewcontroller
            
            let viewController =  OpenMapViewController()
            coordinate = CLLocationCoordinate2DMake(bean.y, bean.x);
            coordinate = CLLocationCoordinate2DMake(bean.y, bean.x).toMars();
            viewController.targetLocation = CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
            viewController.targetDistanceLocation = CLLocation(latitude: self.original_coordinate.latitude, longitude: self.original_coordinate.longitude)
            
            viewController.fromId = bean.fromId
            viewController.msgscrentId = bean.messagessSecretId
            viewController.address = bean.address
            //            nib.msg = bean
            self.presentViewController(viewController, animated:true, completion: nil)
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : MessageRecivedViewCell = tableView.dequeueReusableCellWithIdentifier("MessageRecivedViewCell") as! MessageRecivedViewCell
        
        let bean = msgs[indexPath.row] as MessageBean
        // Configure the cell...
        cell.name.text = "来自：\(bean.from)"
        if bean.avatar.length != 0 {
            cell.imageMe.hnk_setImageFromURL(NSURL(string:bean.avatar)!)
        }
        cell.address.text = bean.address
        cell.question.text = bean.question
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
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
