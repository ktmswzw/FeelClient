//
//  PointUIView.swift
//  FeelingClient
//
//  Created by Vincent on 4/15/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit
import IBAnimatable
import SwiftyJSON
import Alamofire
import Foundation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class PointUIView: UIView{
    
    var disposeBag = DisposeBag()
        var fromId = ""
    @IBOutlet var avator: UIImageView!
    @IBOutlet var question: AnimatableTextField!
    @IBOutlet var answer: AnimatableTextField!
    @IBOutlet var verifyButton: AnimatableButton!
    
    
    weak var delegate: openOverProtocol?
    
    var msgModel: OpenMessageModel!
    
    var msgId:String = "" {
        didSet {

            if(self.question.text!.isEmpty)
            {
//                self.verifyAnswer()
                //self.performSegueWithIdentifier("openOver", sender: self)
            }
            
            
            let questionValid = question.rx_text
                .map { $0.characters.count >= 1 }
                .shareReplay(1)
            
            let answerValid = answer.rx_text
                .map { $0.characters.count >= 1 }
                .shareReplay(1)
            
            let everythingValid = Observable.combineLatest(questionValid,answerValid) { $0 && $1}
                .shareReplay(1)
            
            
            everythingValid
                .bindTo(verifyButton.rx_enabled)
                .addDisposableTo(disposeBag)
            
            
            verifyButton.rx_tap
                .subscribeNext { [weak self] in
                    self?.verifyAnswer()
                }
                .addDisposableTo(disposeBag)
            
            
            
        }
    }
    
    func verifyAnswer()
    {
        msgModel.id = self.msgId
        msgModel.question = self.question.text
        msgModel.answer = self.answer.text
        delegate?.openOverSubmit()
    }
    
}


protocol openOverProtocol: class {
    func openOverSubmit()
}
