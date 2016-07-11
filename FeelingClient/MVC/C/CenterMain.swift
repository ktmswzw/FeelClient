//
//  CenterMain.swift
//  FeelingClient
//
//  Created by vincent on 12/3/16.
//  Copyright © 2016 xecoder. All rights reserved.
//


import UIKit
import MapKit
import CoreLocation
import IBAnimatable
import MobileCoreServices
import Instructions
import Haneke
import IBAnimatable
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

var radar: RadarViewBiBi?

class CenterMain: UIViewController, CoachMarksControllerDataSource,OpenOverProtocol,ARDataSource,AnnotationProtocol,MessageViewModelDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    var locationManager = CLLocationManager()
    
    var selectedView: MKAnnotationView?
    var radarTimer: NSTimer?
    var searchTimer: NSTimer?
    var latitude = 0.0
    var longitude = 0.0
    var targetLocation:CLLocation = CLLocation(latitude: 0, longitude: 0) //目标点火星后
    var targetDistanceLocation:CLLocation = CLLocation(latitude: 0, longitude: 0) //目标点原始距离
    var msgId = ""
    var to = ""
    var isOk = false
    var msgscrentId = ""
    var viewModel: MessageViewModel!
    let cache = Shared.imageCache
    var coachMarksController: CoachMarksController?
    let profileSectionText = "写一封信寄给你的亲人或者朋友，让TA来此地，身临其境的感觉你对TA的思恋"
    let handleText = "搜索你的亲人或者朋友寄给你的信，或者周围有感触的奇妙地点"
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    let nextButtonText = "好"
    var disposeBag = DisposeBag()
    
    let msg: MessageApi = MessageApi.defaultMessages
    
    
    @IBOutlet weak var addNewButton: AnimatableButton!
    @IBOutlet weak var findMoreButton: AnimatableButton!
    
    @IBOutlet var mapView: MKMapView!
    
    var tempView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        viewModel = MessageViewModel(delegate: self)
        
        //导航
        self.coachMarksController = CoachMarksController()
        self.coachMarksController?.allowOverlayTap = true
        
        self.coachMarksController?.dataSource = self
        
        let skipView = CoachMarkSkipDefaultView()
        skipView.setTitle("跳过", forState: .Normal)
        self.coachMarksController?.skipView = skipView
        
        //地图初始化
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 1;
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        //点击
        addNewButton.rx_tap
            .subscribeNext { [weak self] in self?.performSegueWithIdentifier("send", sender: self) }
            .addDisposableTo(disposeBag)
        
        findMoreButton.rx_tap
            .subscribeNext { [weak self] in self?.searchMsg() }
            .addDisposableTo(disposeBag)
        
        
        
        //        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        if(CLLocationManager.authorizationStatus() == .Denied) {
            let aleat = UIAlertController(title: "打开定位开关", message:"定位服务未开启,请进入系统设置>隐私>定位服务中打开开关,并允许Feeling使用定位服务", preferredStyle: .Alert)
            let tempAction = UIAlertAction(title: "取消", style: .Cancel) { (action) in
            }
            let callAction = UIAlertAction(title: "立即设置", style: .Default) { (action) in
                let url = NSURL.init(string: UIApplicationOpenSettingsURLString)
                if(UIApplication.sharedApplication().canOpenURL(url!)) {
                    UIApplication.sharedApplication().openURL(url!)
                }
            }
            aleat.addAction(tempAction)
            aleat.addAction(callAction)
            self.presentViewController(aleat, animated: true, completion: nil)
        }
        
        Constant.Notifi.addObserver(self, selector: #selector(self.hasUnreadMessages), name: Constant.RongCloudUnreadMessageNotifi, object: nil)
        
        Constant.Notifi.addObserver(self, selector: #selector(self.hasUnreadMessagesAPNS), name: Constant.APNSUnreadMessageNotifi, object: nil)
    }
    
    deinit {
        Constant.Notifi.removeObserver(self)
    }
    
    func hasUnreadMessagesAPNS() {
        dispatch_async(dispatch_get_main_queue()) {
            UIApplication.sharedApplication().applicationIconBadgeNumber = Constant.messagecountAPNS + Constant.messagecount
            if Constant.messagecountAPNS != 0 {
                self.tabBarController?.tabBar.items![0].badgeValue = "\(Constant.messagecountAPNS)"
            } else {
                self.tabBarController?.tabBar.items![0].badgeValue = nil
            }
        }
    }
    
    func hasUnreadMessages() {
        dispatch_async(dispatch_get_main_queue()) {
            UIApplication.sharedApplication().applicationIconBadgeNumber = Constant.messagecountAPNS + Constant.messagecount
            if Constant.messagecount != 0 {
                self.tabBarController?.tabBar.items![2].badgeValue = "\(Constant.messagecount)"
            } else {
                self.tabBarController?.tabBar.items![2].badgeValue = nil
            }
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    
    func ar(arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView
    {
        // Annotation views should be lightweight views, try to avoid xibs and autolayout all together.
        let annotationView = TestAnnotationView()
        annotationView.frame = CGRect(x: 0,y: 0,width: 200,height: 50)
        annotationView.delegate = self
        return annotationView;
    }
    
    
    func showAnnotationInfo(annotation: ARAnnotation) {
        var answerField: UITextField?
        
        let alertController: UIAlertController = UIAlertController(title: "你最机智", message: annotation.question, preferredStyle: .Alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "取消", style: .Cancel) { action -> Void in
            print("Pushed CANCEL")
        }
        alertController.addAction(cancelAction)
        
        let logintAction: UIAlertAction = UIAlertAction(title: "芝麻开门", style: .Default) { action -> Void in
            self.openOverSubmit(annotation.id!, answer: (answerField?.text)!)
        }
        alertController.addAction(logintAction)
        
        alertController.addTextFieldWithConfigurationHandler { textField -> Void in
            answerField = textField
            textField.placeholder = annotation.answerTip
        }
        
        alertController.show()
        
    }
    
    
    private func getDummyAnnotations() -> Array<ARAnnotation>
    {
        var annotations: [ARAnnotation] = []
        
        for i in 0.stride(to: self.viewModel.annotationArray.count, by: 1) {
            let annotation = ARAnnotation()
            let myAnnotation = self.viewModel.annotationArray[i]
            annotation.location = CLLocation(latitude: myAnnotation.original_coordinate!.latitude, longitude: myAnnotation.original_coordinate!.longitude)
            annotation.imageUrl = myAnnotation.url
            annotation.title = myAnnotation.title
            annotation.id = myAnnotation.id
            annotation.fromId = myAnnotation.fromId
            annotation.msgId = myAnnotation.id
            annotation.question = myAnnotation.question
            annotation.answerTip = myAnnotation.answerTip
            annotations.append(annotation)
        }
        
        return annotations
    }
    
    func showARViewController()
    {
        // Check if device has hardware needed for augmented reality
        let result = ARViewController.createCaptureSession()
        if result.error != nil
        {
            let message = result.error?.userInfo["description"] as? String
            let alert = UIAlertController(title: "知道", message: message, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // Create random annotations around center point    //@TODO
        //FIXME: set your initial position here, this is used to generate random POIs
        
        let dummyAnnotations = self.getDummyAnnotations()
        
        // Present ARViewController
        let arViewController = ARViewController()
        arViewController.debugEnabled = false
        arViewController.dataSource = self
        arViewController.maxDistance = 0
        arViewController.maxVisibleAnnotations = 100
        arViewController.maxVerticalLevel = 5
        arViewController.headingSmoothingFactor = 0.05
        arViewController.trackingManager.userDistanceFilter = 25
        arViewController.trackingManager.reloadDistanceFilter = 75
        arViewController.setAnnotations(dummyAnnotations)
        self.presentViewController(arViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func buttonTap(sender: AnyObject)
    {
        showARViewController()
    }
    
    
    func openOverSubmit(id:String, answer:String) {        
        
        msg.verifyMsg(id, answer: answer) { (r:BaseApi.Result) in
            switch (r) {
            case .Success(let r):
                self.msgscrentId = r as! String;
                self.view.makeToast("验证成功，前往该地100米之内将开启你们的秘密", duration: 1, position: .Center)
                self.performSegueWithIdentifier("openOver", sender: self)
                self.mapView.removeAnnotation((self.selectedView?.annotation)!)
                break;
            case .Failure(let msg):
                self.view.makeToast(msg as! String, duration: 1, position: .Center)
                break;
            }
        }
    }
    
    
    /**
     图标列表
     **/
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //自定义地图图标
        
        if annotation.isKindOfClass(MKUserLocation) {
            //            let annotationView =  MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
            //            let fetcher = NetworkFetcher<UIImage>(URL: NSURL(string: jwt.userAvator)!)
            //            cache.fetch(fetcher: fetcher).onSuccess { image in
            //                annotationView.image =  Toucan(image: image).maskWithEllipse(borderWidth: 3, borderColor: UIColor ( red: 0.0, green: 0.4784, blue: 1.0, alpha: 1.0 )).image
            //            }
            //            annotationView.canShowCallout = true
            //            return annotationView
            return nil
        }
        
        if annotation is MyAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("annotationView")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
                annotationView!.canShowCallout = true
                if let pin = annotation as? MyAnnotation {
                    let two:UIImage
                    //                    if pin.type == 0 {
                    two = UIImage(named: "pin")!
                    //                    }
                    //                    else {
                    //                        two = UIImage(named: "pin_color")!
                    //                    }
                    
                    let fetcher = NetworkFetcher<UIImage>(URL: NSURL(string: pin.url!)!)
                    //                    cache.fetch(fetcher: fetcher).onSuccess { image in
                    //                        annotationView?.image =  Toucan(image: image).maskWithEllipse(borderWidth: 3, borderColor: UIColor ( red: 0.0, green: 0.4784, blue: 1.0, alpha: 1.0 )).image
                    //                    }
                    
                    //                    
                    cache.fetch(fetcher: fetcher).onSuccess { image in
                        //annotationView?.image = image
                        annotationView?.image = getPin(image, two: two)
                    }
                }
            }
            return annotationView
        }
        else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DEFAULT")
            return annotationView
        }
    }
    
    
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        selectedView = view;
        
        if let pin = view.annotation as? MyAnnotation {
            viewModel.msgId = pin.id as String
            if let q:String = pin.subtitle  {
                viewModel.question = q
            }
            if let t:String = pin.title {
                viewModel.to = t
            }
            if let id:String = pin.fromId {
                viewModel.fromId = id
            }
            self.targetLocation = CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)
            self.targetDistanceLocation = CLLocation(latitude: pin.original_coordinate!.latitude, longitude: pin.original_coordinate!.longitude)
            
            
            
            let detailView = NSBundle.mainBundle().loadNibNamed("point", owner: self, options: nil)[0] as! PointUIView
            detailView.delegate = self
            if let url:String = pin.url! as String {
                let URL = NSURL(string: url)!
                let fetcher = NetworkFetcher<UIImage>(URL: URL)
                cache.fetch(fetcher: fetcher).onSuccess { image in
                    detailView.avator.image = image
                }
            }
            detailView.answer.placeholder = "提示：\(pin.answerTip!)"
            detailView.msgId = pin.id
            detailView.fromId = pin.fromId!
            detailView.question.text = pin.question
            
            
            view.detailCalloutAccessoryView = detailView
        }
    }
    
    func searchMsg() {
        
        if !userDefaults.boolForKey("NEWONESHOW") && jwt.jwtTemp != ""  {
            self.coachMarksController!.startOn(self)
            userDefaults.setBool(true, forKey: "NEWONESHOW")
            userDefaults.synchronize()
        }
        else
        {
            //雷达图
            addTempView()
            radar?.isStart = true
            viewModel.longitude = self.longitude
            viewModel.latitude = self.latitude
            self.mapView.removeAnnotations(mapView.annotations)
            findMoreButton.enabled = false
            findMoreButton.hidden = true
            searchTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(searchTimerFunc), userInfo: nil, repeats: false)
            radarTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(stopRadar), userInfo: nil, repeats: false)
        }
    }
    
    func searchTimerFunc()
    {
        viewModel.searchMessage(self.to,map: self.mapView, view: self.view)
        
        Constant.messagecountAPNS = 0
        Constant.Notifi.postNotificationName(Constant.APNSUnreadMessageNotifi, object: nil)
    }
    
    func stopRadar()
    {
        radar?.isStart = false
        findMoreButton.enabled = true
        findMoreButton.hidden = false
        tempView.removeFromSuperview()
    }
    
    func addTempView(){
        tempView = UIView(frame: CGRect(x: 0, y: 0, width: self.mapView.bounds.width, height: self.mapView.bounds.height))
        tempView.alpha = 1
        radar = RadarViewBiBi.init(frame: CGRectMake(100, 100, 0, 0))
        radar!.backgroundColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        radar!.center = self.view.center
        tempView.addSubview(radar!)
        self.mapView.addSubview(tempView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "send" {
            let bottomBar = segue.destinationViewController as! CenterViewController
            bottomBar.hidesBottomBarWhenPushed = true
        }
        else if segue.identifier == "openOver" {
            let viewController = segue.destinationViewController as! OpenMapViewController
            viewController.targetDistanceLocation = self.targetDistanceLocation
            viewController.targetLocation = self.targetLocation
            viewController.fromId = self.viewModel.fromId
            viewController.msgscrentId = self.msgscrentId
            viewController.address = self.viewModel.address
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
        latitude =  location!.coordinate.latitude
        longitude = location!.coordinate.longitude
        
        if(!isOk){
            
            UIView.animateWithDuration(1.5, animations: { () -> Void in
                let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                self.mapView.region = region
                self.isOk = true
                self.locationManager.stopUpdatingLocation()
                self.locationManager.delegate = nil;
                
                self.searchMsg()
            })
        }
        
    }
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Protocol Conformance | CoachMarksControllerDataSource
    func numberOfCoachMarksForCoachMarksController(coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarksForIndex index: Int) -> CoachMark {
        switch(index) {
        case 0:
            return coachMarksController.coachMarkForView(self.addNewButton)
        case 1:
            return coachMarksController.coachMarkForView(self.findMoreButton)
        default:
            return coachMarksController.coachMarkForView()
        }
    }
    
    func coachMarksController(coachMarksController: CoachMarksController, coachMarkViewsForIndex index: Int, coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        let coachViews = coachMarksController.defaultCoachViewsWithArrow(true, arrowOrientation: coachMark.arrowOrientation)
        
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = self.profileSectionText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        case 1:
            coachViews.bodyView.hintLabel.text = self.handleText
            coachViews.bodyView.nextLabel.text = self.nextButtonText
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    
    
}
