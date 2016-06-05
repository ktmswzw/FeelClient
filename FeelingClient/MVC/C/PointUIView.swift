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

class PointUIView: AnimatableView{
    
    var disposeBag = DisposeBag()
        var fromId = ""
    @IBOutlet var avator: UIImageView!
    @IBOutlet var question: AnimatableTextField!
    @IBOutlet var answer: AnimatableTextField!
    @IBOutlet var verifyButton: AnimatableButton!
    
    
    weak var delegate: OpenOverProtocol?
    
    
    var msgId:String = "" {
        didSet {
                        
            let questionValid = question.rx_text
                .map { $0.characters.count >= 0 }
                .shareReplay(1)
            
            let answerValid = answer.rx_text
                .map { $0.characters.count >= 1 }
                .shareReplay(1)
            
            let everythingValid = Observable.combineLatest(questionValid,answerValid) {
                $0 && $1 || self.question.text!.isEmpty
                }
                .shareReplay(1)
            
            everythingValid
                .bindTo(verifyButton.rx_enabled)
                .addDisposableTo(disposeBag)
            
            verifyButton.rx_tap
                .subscribeNext { [weak self] in
                    self!.verifyButton.alpha = 1
                    self?.verifyAnswer()
                }
                .addDisposableTo(disposeBag)
            
            
            
        }
    }
    
    func verifyAnswer()
    {        
        delegate?.openOverSubmit(self.msgId, answer: self.answer.text!)
    }
    
}


protocol OpenOverProtocol: class {
    func openOverSubmit(id:String, answer:String)
}
