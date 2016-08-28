//
//  MessageInfoViewController.swift
//  FeelingClient
//
//  Created by Vincent on 16/5/25.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import UIKit
import MediaPlayer
import Eureka


class MessageInfoViewController: FormViewController {
    
    @IBOutlet var button: UIButton!
    
    var msg: MessageBean!
    
    let msgApi: MessageApi = MessageApi.defaultMessages
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.navigationItem.title = "信息"
        //        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MessageInfoViewController.close))
        // self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        form =  Section("信息")
            <<< TextRow("to"){ $0.title = "收件人"
                $0.disabled = true
                $0.value = msg.to
            }
            
            
            <<< TextAreaRow("content") {
                $0.title = "内容"
                $0.placeholder = "内容"
                $0.value = msg.content
            }
            
            <<< TextRow("question") {
                $0.title = "问题"
                $0.disabled = true
                $0.value = msg.question
            }
            
            <<< TextRow("answer") {
                $0.title = "答案"
                $0.disabled = true
                $0.value = msg.answer
            }
            
            <<< TextRow("address") {
                $0.title = "地址"
                $0.disabled = true
                $0.value = msg.address
            }
            
            <<< LabelRow("open") {
                $0.title = "开启人："
                $0.disabled = true
                $0.value =  msg.from
            }
            
            +++ Section("操作")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "返回"
                }  .onCellSelection({ (cell, row) in
                    self.close()
                })
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "详情"
                }  .onCellSelection({ (cell, row) in
                    self.performSegueWithIdentifier("nnnn", sender: nil);
                })
    }
    
    func dropMessage(id: String)
    {
        msgApi.drop(id) { (r:BaseApi.Result) in
            switch (r) {
            case .Success(_):
                self.view.makeToast("删除成功", duration: 1, position: .Center)
                self.close()
                break;
            case .Failure(let msg):
                self.view.makeToast(msg as! String, duration: 1, position: .Center)
                break;
            }
        }
    }
    
    func close()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "nnnn" {
            print(1)
        }
        
    }
}



