import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage

class PhotoUpLoader:BaseApi {
    private var uploadMgr: TXYUploadManager!;
    private var sign = "",signFile="";
    private var bucket = "habit";
    private var appId = "10005997";
    
    private var bucket_file = "test";
    private var appId_file = "10043128";
    
    private var semaphore: dispatch_semaphore_t?;
    private var queue: dispatch_queue_t = dispatch_get_global_queue(0, 0);
    
    static let sharedInstance = PhotoUpLoader()
    
    
    override init()
    {
        super.init()
        if jwt.sign.length == 0 {
            initSign()
        }
        else
        {
            self.sign = jwt.sign
            self.signFile = jwt.sign_file
        }
    }
    
    func initSign()  {
        if sign.length == 0  {
            let headers = jwt.getHeader(jwt.token, myDictionary: Dictionary<String,String>())            
            NetApi().makeCall(Alamofire.Method.GET, section: "user/imageSign", headers: headers, params: [:], completionHandler: { (result:BaseApi.Result) -> Void in
                
                switch (result) {
                case .Success(let r):
                    if let temp = r {
                        let myJosn = JSON(temp)
                        let signString = myJosn.dictionary!["message"]!.stringValue
                        let fullNameArr = signString.characters.split {$0 == ","}
                        if fullNameArr.count > 1 {
                            jwt.sign = String(fullNameArr[0])
                            jwt.sign_file = String(fullNameArr[1])
                            self.sign = jwt.sign
                            self.signFile = jwt.sign_file
                        }
                        else {
                            break
                        }
                        
                    }
                    break;
                case .Failure(let error):
                    print("\(error)")
                    break;
                }
                
                
            })
            
        }
    }
    
    
    func getPathZip(image: UIImage) -> NSData{
        let size = CGSize(width: 400.0, height: 400.0)
        let scaledImage = image.af_imageScaledToSize(size)
        guard let data = UIImageJPEGRepresentation(scaledImage,0.7) else {//jpg
            return UIImagePNGRepresentation(scaledImage)! //png
        }
        return data
    }
    
    
    
    func completionAll(imageData:[UIImage], finishDo: CompletionHandlerType){
        var path:String = ""
        var count = 0;
        for element in imageData {
            self.uploadToTXY(element, name: "\(arc4random())", completionHandler: { (result:Result) -> Void in
                switch (result) {
                case .Success(let pathIn):
                    if let temp = pathIn {
                        if path.length == 0 {
                            path = temp as! String
                        }else{
                            path = path + "," + (temp as! String)
                        }
                    }
                    
                    count += 1
                    
                    if count == imageData.count {
                        finishDo(Result.Success(path))
                    }
                    break;
                case .Failure(let error):
                    finishDo(Result.Failure(error))
                    break;
                }
            })
        }
    }
    
    
    
    
    /// 上传至万象优图
    func uploadToTXY(image: UIImage,name: String,completionHandler: CompletionHandlerType ) {
        let data = getPathZip(image)
        if data.length == 0 {
            NSLog("没有data");
            completionHandler(Result.Failure(""))
            return;
        }
        
        
        if self.sign.length == 0 {
            NSLog("没有sign");
            completionHandler(Result.Failure(""))
            return;
        }
        uploadMgr = TXYUploadManager(cloudType: TXYCloudType.ForImage, persistenceId: "photoUploadMgr", appId: self.appId);
        if uploadMgr == nil {
            semaphore = dispatch_semaphore_create(0);
        }
        dispatch_async(queue) {[weak self] () -> Void in
            if self?.semaphore != nil {
                NSLog("开始等待获取到签名信号");
                let timer = dispatch_time(DISPATCH_TIME_NOW, Int64(15) * Int64(NSEC_PER_SEC));
                dispatch_semaphore_wait((self?.semaphore)!, timer);
                self?.semaphore = nil
                NSLog("结束等待获取到签名信号");
            }
            if self?.uploadMgr == nil {
                NSLog("不能开始上传, 万象优图上传管理器没有创建...");
                completionHandler(Result.Failure(""));
                return;
            }
            let uploadNode = TXYPhotoUploadTask(imageData: data, fileName: name, sign: self!.sign, bucket: self!.bucket, expiredDate: 0, msgContext: "", fileId: nil);
            self?.uploadMgr.upload(uploadNode, complete: { (rsp: TXYTaskRsp!, context: [NSObject : AnyObject]!) -> Void in
                if let photoResp = rsp as? TXYPhotoUploadTaskRsp {
                    NSLog(photoResp.photoFileId);
                    NSLog(photoResp.photoURL);
                    
                    completionHandler(Result.Success(photoResp.photoFileId))
                }
                }, progress: {(total: Int64, complete: Int64, context: [NSObject : AnyObject]!) -> Void in
                    NSLog("progress total:\(total) complete:\(complete)");
                }, stateChange: {(state: TXYUploadTaskState, context: [NSObject : AnyObject]!) -> Void in
                    NSLog("stateChange:\(state)");
            })
        };
    }
    
    /// 上传至Qcloud COS
    func uploadAudioToTXY(path: String,name: String,completionHandler: CompletionHandlerType ) {
        if path.length == 0 {
            NSLog("没有data");
            completionHandler(Result.Failure(""))
            return;
        }
        //        let tmp = NSHomeDirectory() + "/Documents"
        let path_tmp = path.replaceMatches("file://", withString: "", ignoreCase: false)
        
        
        if self.signFile.length == 0 {
            NSLog("没有sign");
            completionHandler(Result.Failure(""))
            return;
        }
        uploadMgr = TXYUploadManager(cloudType: TXYCloudType.ForFile, persistenceId: "test", appId: self.appId_file);
        if uploadMgr == nil {
            semaphore = dispatch_semaphore_create(0);
        }
        dispatch_async(queue) {[weak self] () -> Void in
            if self?.semaphore != nil {
                NSLog("开始等待获取到签名信号");
                let timer = dispatch_time(DISPATCH_TIME_NOW, Int64(15) * Int64(NSEC_PER_SEC));
                dispatch_semaphore_wait((self?.semaphore)!, timer);
                self?.semaphore = nil
                NSLog("结束等待获取到签名信号");
            }
            if self?.uploadMgr == nil {
                NSLog("不能开始上传, cos上传管理器没有创建...");
                completionHandler(Result.Failure(""));
                return;
            }
            
            let fileTask = TXYFileUploadTask(path: path_tmp, sign: self!.signFile, bucket: self!.bucket_file, customAttribute: nil, uploadDirectory: "/baron", msgContext: nil);
            sleep(1)
            self?.uploadMgr.upload(fileTask, complete: { (rsp: TXYTaskRsp!, context: [NSObject : AnyObject]! ) -> Void in
                
                if let fileResp = rsp as? TXYFileUploadTaskRsp {
                    NSLog(fileResp.fileURL);
                    
                    completionHandler(Result.Success(fileResp.fileURL))
                }
                }, progress: {(total: Int64, complete: Int64, context: [NSObject : AnyObject]!) -> Void in
                    NSLog("progress total:\(total) complete:\(complete)");
                }, stateChange: {(state: TXYUploadTaskState, context: [NSObject : AnyObject]!) -> Void in
                    NSLog("stateChange:\(state)");
            })
        };
    }
    
}
