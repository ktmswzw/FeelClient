//
//  NetApiAlamofire.swift
//  FeelingClient
//
//  Created by vincent on 13/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

import SwiftyJSON

class NetApi:BaseApi {
    
        var apiUrl = "http://61.164.187.56:8080/"
//    var apiUrl = "http://192.168.9.105:8080/"
    
    //简单数据
    func makeCallString(method: Alamofire.Method, section: String, headers: [String: String]?, params: [String: AnyObject]?, completionHandler: CompletionHandlerType) {
        Alamofire.request(method, apiUrl+section,headers: headers, parameters: params)
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    completionHandler(Result.Success(value))
                case .Failure(let error):
                    completionHandler(Result.Failure(error))
                }
        }
    }
    
    //JSON数据
    func makeCall(method: Alamofire.Method, section: String, headers: [String: String]?, params: [String: AnyObject]?, completionHandler: CompletionHandlerType) {
        Alamofire.request(method, apiUrl+section,headers: headers, parameters: params)
            .responseJSON { response in
                switch response.result {
                case .Success(let value):
                    completionHandler(Result.Success(value as? NSDictionary))
                case .Failure(let error):
                    completionHandler(Result.Failure(error))
                }
        }
    }
    
    
    //array数据列表
    func makeCallArray<T: Mappable>(method: Alamofire.Method, section: String, headers: [String: String]?, params: [String: AnyObject]?,
                       completionHandler: Response<[T], NSError> -> Void ) {
        Alamofire.request(method, apiUrl+section,headers: headers, parameters: params)
            .responseArray { (response: Response<[T], NSError>) in
                completionHandler(response)
        }
    }
    
    //json类
    func makeCallBean<T: Mappable>(method: Alamofire.Method, section: String, headers: [String: String]?, params: [String: AnyObject]?,
                      completionHandler: Response<T, NSError> -> Void ) {
        NSLog("\(apiUrl)/\(section)")
        Alamofire.request(method, apiUrl+section,headers: headers, parameters: params)
            .responseObject {
                (response: Response<T, NSError>) in
                completionHandler(response)
        }
    }
    
    
}
