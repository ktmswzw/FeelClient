//
//  FriendsViewController.swift
//  FeelingClient
//
//  Created by vincent on 16/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit

import MapKit

class FriendsViewController: UITableViewController {
    
    var viewModel: FriendViewModel!
    
    
    override func viewDidAppear(animated: Bool) {
        moveToSeoul()
    }
    
    func moveToSeoul() {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        viewModel.friends.removeAll()
        super.viewWillAppear(true)
        self.refreshData()
    }
    
    func refreshData()
    {
        if refreshControl != nil {
            refreshControl!.beginRefreshing()
        }
        refresh(refreshControl!)
    }
    
    func getFriends()
    {
        viewModel.searchMsg("") { (r: BaseApi.Result) in
            
        }
    }
    
    func refresh(sender: AnyObject) {
        
        viewModel.friends.removeAll()
        getFriends()
        refreshControl!.endRefreshing()

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return books.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookInfo", forIndexPath: indexPath) as! BookTableViewCell
        
        // Configure the cell...
        let bookCell = books[indexPath.row] as Book
        cell.title.text = bookCell.title
        cell.id.text = bookCell.id
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        cell.content.text = dateFormatter.stringFromDate(bookCell.publicDate)
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let bookCell = books[indexPath.row] as Book
            books.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            let jwt = JWTTools()
            let newDict: [String: String] = [:]//["id": bookCell.id]
            let headers = jwt.getHeader(jwt.token, myDictionary: newDict)
            Alamofire.request(.DELETE, "http://192.168.137.1:80/book/pathDelete/\(bookCell.id)",headers:headers)
                .responseJSON { response in
                    
            }
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showBook" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = books[indexPath.row] as Book
                (segue.destinationViewController as! BookViewController).detailItem = object
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
