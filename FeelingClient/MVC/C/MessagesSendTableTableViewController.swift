//
//  MessagesSendTableTableViewController.swift
//  FeelingClient
//
//  Created by Vincent on 16/5/2.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import UIKit
import Foundation
import XLPagerTabStrip

class MessagesSendTableTableViewController: UITableViewController,MessageViewModelDelegate,IndicatorInfoProvider {
    
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

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //设置背景颜色
        refreshControl!.backgroundColor = UIColor ( red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0 )
        //设置菊花转的颜色
        refreshControl!.tintColor = UIColor ( red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0 )
        
        //往tableView添加刷新控件
        self.tableView.addSubview(refreshControl!)
        
        self.tableView.registerNib(UINib(nibName: "MessageSendViewCell", bundle: nil), forCellReuseIdentifier: "MessageSendViewCell")
        getMessages()
    }
    
    func getMessages()
    {
        self.navigationController?.view.makeToastActivity(.Center)
        self.msg.querySendAndRecived(true, page: 1, size: 1000, completeHander: { (r: BaseApi.Result) in
            switch (r) {
            case .Success(let value):
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
            if msgs.count != 0 {
                msgs.removeAll()
            }
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if msgs.count > 0 {
            let bean = msgs[indexPath.row] as MessageBean
            let nib = MessageInfoViewController()//需要跳转的viewcontroller
            nib.msg = bean
            self.presentViewController(nib, animated:true, completion: nil)
            
            
//            self.performSegueWithIdentifier("infoMessage", sender: self)
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : MessageSendViewCell = tableView.dequeueReusableCellWithIdentifier("MessageSendViewCell") as! MessageSendViewCell
        if msgs.count > 0 {
            let bean = msgs[indexPath.row] as MessageBean
            // Configure the cell...
            cell.name.text = "\(bean.from)"
            if bean.avatar.length != 0 {
                cell.imagesMe.hnk_setImageFromURL(NSURL(string:bean.avatar)!)
            }
            cell.tryCount.text = "\(bean.tryCount)"
            cell.question.text = bean.question
        }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "infoMessage" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = msgs[indexPath.row] as MessageBean
                (segue.destinationViewController as! MessageInfoViewController).msg = object
            }
        }
    }
 
    
}
