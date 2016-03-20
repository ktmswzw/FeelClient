
import UIKit

import ObjectMapper

public class BaseModel: NSObject,Mappable {
    
    var errorCode:String = "0"
    override init() {}
    required public init?(_ map: Map) {
        super.init()
        mapping(map)
    }
    
    class func newInstance() -> Mappable {
        return BaseModel()
    }
    
    public func mapping(map: Map) {
        errorCode <- map["errorCode"]
    }
    
    func toParams() -> [String: AnyObject] {
        
        return Mapper().toJSON(self)
    }
    
}

public class BaseApi:NSObject {
    
    typealias CompletionHandlerType = (Result) -> Void
    
    enum Result {
        case Success(AnyObject?)
        case Failure(AnyObject?)
    }
    
    enum Error: ErrorType {
        case AuthenticationFailure
    }
}
