//
//  OpenMessageViewController.swift
//  FeelingClient
//
//  Created by vincent on 20/3/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit
import IBAnimatable
import SwiftyJSON
import Alamofire
import MapKit
import CoreLocation
import Foundation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class OpenMessageViewController: DesignableViewController,UITextFieldDelegate,OpenMessageModelDelegate {
    
    var viewModel: MessageViewModel!
    var msgModel: OpenMessageModel!
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var questionLabel: AnimatableTextField!
    @IBOutlet weak var answerLabel: AnimatableTextField!
    @IBOutlet weak var verifyButton: AnimatableButton!
    @IBOutlet weak var alertLable: AnimatableLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        let image = UIImage(named: "lonely-children")//lonely-children
        let blurredImage = image!.imageByApplyingBlurWithRadius(15)
        self.view.layer.contents = blurredImage.CGImage
        
        msgModel = OpenMessageModel(delegate: self)
        
        var name = viewModel.to
        if(name.isEmpty){
            name = "TA"
        }
        var title = "设置了密码"
        if(viewModel.question.isEmpty)
        {
            title = "没有设置密码"
            self.performSegueWithIdentifier("openOver", sender: self)
        }
        
        alertLable.text = name + title
        
        
        questionLabel.text = viewModel.question
        
        let questionValid = questionLabel.rx_text
            .map { $0.characters.count >= 1 }
            .shareReplay(1)
        
        let answerValid = answerLabel.rx_text
            .map { $0.characters.count >= 1 }
            .shareReplay(1)
        
        let everythingValid = Observable.combineLatest(questionValid, answerValid) { $0 && $1}
            .shareReplay(1)
        
        
        everythingValid
            .bindTo(verifyButton.rx_enabled)
            .addDisposableTo(disposeBag)
        
        
        verifyButton.rx_tap
            .subscribeNext { [weak self] in
                self?.verifyAnswer()
            }
            .addDisposableTo(disposeBag)
        
        
        self.navigationController?.view.hideToastActivity()

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "openOver" {
            let viewController = segue.destinationViewController as! OpenMapViewController
            viewController.targetLocation = CLLocation(latitude: self.viewModel.latitude, longitude: self.viewModel.longitude)
            viewController.msgModel = self.msgModel
            viewController.fromId = self.viewModel.fromId
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func verifyAnswer()
    {
        self.navigationController?.view.makeToastActivity(.Center)
        msgModel.id = self.viewModel.msgId
        msgModel.question = self.viewModel.question
        msgModel.answer = self.answerLabel.text
        //        msgModel.verifyAnswer(self.view,uc: self)
        
            self.msgModel.verifyAnswer2(self.view) { (r:BaseApi.Result) in
                switch (r) {
                case .Success(let r):
                    self.msgModel.msgscrentId = r as! String;
                    self.navigationController?.view.hideToastActivity()
                    self.view.makeToast("验证成功，前往该地100米之内将开启你们的秘密", duration: 1, position: .Center)
                    sleep(1)
                    self.performSegueWithIdentifier("openOver", sender: self)
                    
                    break;
                case .Failure(let msg):
                    self.navigationController?.view.hideToastActivity()
                    self.view.makeToast(msg as! String, duration: 1, position: .Center)
                    break;
                }
            }
        
        
    }
    
}
