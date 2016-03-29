//
//  OpenMessageModel.swift
//  FeelingClient
//
//  Created by Vincent on 3/29/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

enum ValidationResult {
    case OK(message: String)
    case Empty
    case Validating
    case Failed(message: String)
}

enum VerifyState {
    case verified(verified: Bool)
}

protocol OpenMessageAPI {
    func answerAvailable(answer: String,msgId: String) -> Observable<Bool>
}

protocol OpenMessageService {
    func answerAvailable(answer: String,msgId: String) -> Observable<Bool>
}

extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .OK:
            return true
        default:
            return false
        }
    }
}