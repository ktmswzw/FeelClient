//
//  AppDelegate.swift
//  FeelingClient
//
//  Created by vincent on 11/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit
import CoreData
import SwiftyDB
import SwiftyJSON
import Alamofire
import Chirp
var jwt = JWTTools()

var loader:PhotoUpLoader = PhotoUpLoader()
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UserInfoModelDelegate, RCIMConnectionStatusDelegate, RCIMUserInfoDataSource, RCIMGroupInfoDataSource, RCIMReceiveMessageDelegate{
    var updateToken = false //已更新
    var window: UIWindow?
    var viewModel: UserInfoViewModel!
    let cacheDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        return urls[urls.endIndex-1]
    }()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        viewModel = UserInfoViewModel(delegate: self)
        
        
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        Chirp.sharedManager.prepareSound(fileName: "got.wav")
        Chirp.sharedManager.prepareSound(fileName: "no.wav")
        Chirp.sharedManager.prepareSound(fileName: "send.wav")

        initRIM()
        
        return true
    }
    
    func initRIM()
    {
        
        //初始化SMS－SDK ,在MOB后台注册应用并获得AppKey 和AppSecret
        SMSSDK.registerApp("f7b6d783cb00", withSecret: "164aabea58f5eb4723f366eafb0eadf0")
        
        RCIM.sharedRCIM().initWithAppKey("25wehl3uwkppw")
        
        
        //设置监听连接状态
        RCIM.sharedRCIM().connectionStatusDelegate = self
        //设置消息接收的监听
        RCIM.sharedRCIM().receiveMessageDelegate = self
        
        //设置用户信息提供者，需要提供正确的用户信息，否则SDK无法显示用户头像、用户名和本地通知
        RCIM.sharedRCIM().userInfoDataSource = self
        //设置群组信息提供者，需要提供正确的群组信息，否则SDK无法显示群组头像、群名称和本地通知
        RCIM.sharedRCIM().groupInfoDataSource = self
        
        RCIM.sharedRCIM().enableReadReceipt = true
        
        
        RCIM.sharedRCIM().enableTypingStatus = true
        
    }
    
    // 注册通知 alert 、 sound 、 badge （ 8.0 之后，必须要添加下面这段代码，否则注册失败）
    func application(application: UIApplication , didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings ) {
        application.registerForRemoteNotifications ()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    deinit {
        // Cleanup is really simple!
        Chirp.sharedManager.removeSound(fileName: "got.wav")
        Chirp.sharedManager.removeSound(fileName: "no.wav")
        Chirp.sharedManager.removeSound(fileName: "send.wav")
    }
    
    //推送处理3
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var rcDevicetoken = deviceToken.description
        rcDevicetoken = rcDevicetoken.stringByReplacingOccurrencesOfString("<", withString: "")
        rcDevicetoken = rcDevicetoken.stringByReplacingOccurrencesOfString(">", withString: "")
        rcDevicetoken = rcDevicetoken.stringByReplacingOccurrencesOfString(" ", withString: "")
        print("\(rcDevicetoken)")
        if !updateToken {
            self.updateToken = true
            viewModel.updateDeviceToken(rcDevicetoken) { (r:BaseApi.Result) in
                switch (r) {
                case .Success(_):
                    break;
                case .Failure(_):
                    
                    break;
                }
            }
        }
        RCIMClient.sharedRCIMClient().setDeviceToken(rcDevicetoken)
    }
    
    //推送处理4
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("userInfo==\(userInfo)")
        for (_, value) in userInfo {
            for (key2, value2) in (value as? NSDictionary)!  {
                if key2 as! String == "badge" {
                    let badge = "\(value2)"
                    let tabController = self.window?.rootViewController as! UITabBarController
                    let now_count = (tabController.tabBar.items?[1].badgeValue)
                    var  count = 0
                    if Int(badge ) != nil {
                        if now_count != nil {
                            count = Int(now_count!)! + Int(badge)!
                        }
                        else{
                            count = Int(badge)!
                        }
                    }
                    tabController.tabBar.items?[1].badgeValue = "\(count)"
                }
            }
        }

        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Recived: \(userInfo)")
        
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        //本地通知
    }
    
    //监听连接状态变化
    func onRCIMConnectionStatusChanged(status: RCConnectionStatus) {
        print("RCConnectionStatus = \(status.rawValue)")
        if status.rawValue != 0 && status.rawValue != 10 && status.rawValue != 11 {
                loginRIM()
        }
    }
    
    //用户信息提供者。您需要在completion中返回userId对应的用户信息，SDK将根据您提供的信息显示头像和用户名
    func getUserInfoWithUserId(userId: String!, completion: ((RCUserInfo!) -> Void)!) {
        print("用户信息提供者，getUserInfoWithUserId:\(userId)")
        
        let database = SwiftyDB(databaseName: "UserInfo")
        
        let list = database.objectsForType(UserInfo.self, matchingFilter: ["id": userId]).value!
        
        if list.count > 0 {
            let userinfo = list[0]
            completion(RCUserInfo(userId: userId, name: userinfo.nickname, portrait: userinfo.avatar))
        }
        else{
            let params = [:]
            let headers = jwt.getHeader(jwt.token, myDictionary: Dictionary<String,String>())
            NetApi().makeCallBean(Alamofire.Method.GET, section: "user/\(userId)", headers: headers, params: (params as! [String : AnyObject])) { (res:Response<UserInfo, NSError>) in
                switch (res.result) {
                case .Success(let userInfo):
                    database.addObject(userInfo, update: true)
                    completion(RCUserInfo(userId: userId, name: userInfo.nickname, portrait: userInfo.avatar))
                    break
                case .Failure(let error):
                    completion(RCUserInfo(userId: userId, name: "新用户", portrait: ""))
                    print(error)
                    break
                }
            }
        }
        
        
    }
    
    
    //群组信息提供者。您需要在Block中返回groupId对应的群组信息，SDK将根据您提供的信息显示头像和群组名
    func getGroupInfoWithGroupId(groupId: String!, completion: ((RCGroup!) -> Void)!) {
        print("群组信息提供者，getGroupInfoWithGroupId:\(groupId)")
        
        //简单的示例，根据groupId获取对应的群组信息并返回
        //建议您在本地做一个缓存，只有缓存没有该群组信息的情况下，才去您的服务器获取，以提高用户体验
        if (groupId == "group01") {
            //如果您提供的头像地址是http连接，在iOS9以上的系统中，请设置使用http，否则无法正常显示
            //具体可以参考Info.plist中"App Transport Security Settings->Allow Arbitrary Loads"
            completion(RCGroup(groupId: groupId, groupName: "第一个群", portraitUri: "http://www.rongcloud.cn/images/newVersion/logo/aipai.png"))
        } else {
            completion(RCGroup(groupId: groupId, groupName: "unknown", portraitUri: "http://www.rongcloud.cn/images/newVersion/logo/qiugongl.png"))
        }
    }
    
    //监听消息接收
    func onRCIMReceiveMessage(message: RCMessage!, left: Int32) {
        if (left != 0) {
            print("收到一条消息，当前的接收队列中还剩余\(left)条消息未接收，您可以等待left为0时再刷新UI以提高性能")
        } else {
            print("收到一条消息")
        }
        let tabController = self.window?.rootViewController as! UITabBarController
        let now_count = (tabController.tabBar.items?[2].badgeValue)
        var  count = 0
        if now_count != nil {
            count = Int(now_count!)! + Int(left)
        }
        else {
            count = 1
        }
        tabController.tabBar.items?[2].badgeValue = "\(count)"
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xecoder.FeelingClient" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("FeelingClient", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("FeelingClinet.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch let error as NSError {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error
            let wrappedError = NSError(domain: "www.xecoder.com", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        } catch {
            // dummy
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}
