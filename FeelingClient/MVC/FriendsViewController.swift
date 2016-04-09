//
//  FriendsViewController.swift
//  FeelingClient
//
//  Created by vincent on 16/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit
import MapKit
import Haneke

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class FriendsViewController: UITableViewController ,UISearchBarDelegate{
    
    var disposeBag = DisposeBag()
    var viewModel: FriendViewModel!
    var searchName = ""
        @IBOutlet weak var search: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = FriendViewModel(delegate: self)
        
        self.navigationItem.title = "好友列表"
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FriendsViewController.edit))
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.search.rx_text
            .debounce(0.5, scheduler: MainScheduler.asyncInstance)
            .subscribeNext { searchText in
                self.searchName = searchText
                self.refresh(searchText)
            }
            .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.refreshData()
    }
    
    
    func edit()
    {
        
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
        viewModel.searchMsg(self.searchName) { (r: BaseApi.Result) in
            switch (r) {
            case .Success(let value):
                self.viewModel.friends =  value as! [FriendBean]
                self.tableView.reloadData()
                self.search.endEditing(true)
                break;
            case .Failure(let msg):
                print("\(msg)")
                break;
            }
        }
    }
    @IBAction func refresh(sender: AnyObject) {
        if viewModel.friends.count != 0 {
            viewModel.friends.removeAll()
        }
        getFriends()
        refreshControl!.endRefreshing()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.friends.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendInfo", forIndexPath: indexPath) as! FriendTableViewCell
        
        let friendCell = viewModel.friends[indexPath.row] as FriendBean
        cell.remark.text = friendCell.remark
        cell.id.text = friendCell.id
        cell.motto.text = friendCell.motto
        cell.avatar.hnk_setImageFromURL(NSURL(string:friendCell.avatar)!)
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showInfo" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = viewModel.friends[indexPath.row] as FriendBean
                (segue.destinationViewController as! UserInfoViewController).friend = object
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func save(){
        
    }
    func black(){
        
    }
    func search(name:String){
        
    }
}


extension FriendsViewController: FriendModelDelegate{
    
}