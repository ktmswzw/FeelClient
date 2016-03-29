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
import Foundation
import UIKit
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
        
        alertLable.text = "TA设置了密码，提示"
        
        questionLabel.text = self.viewModel.question
        
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
            .subscribeNext { [weak self] in self?.verifyAnswer() }
            .addDisposableTo(disposeBag)
        
        
    }
    
    func showAlert() {
        
        //self.view.makeToast(myJosn.dictionary!["message"]!.stringValue, duration: 2, position: .Center)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func verifyAnswer()
    {
        msgModel.id = self.viewModel.msgId
        msgModel.question = self.viewModel.question
        msgModel.verifyAnswer(self.view)
    }
    
    func arrival()
    {
        msgModel.x = viewModel.latitude
        msgModel.y = viewModel.longitude
        msgModel.arrival(self.view)
    }
    
}
