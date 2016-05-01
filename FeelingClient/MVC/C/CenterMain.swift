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

class CenterMain: UIViewController,CoachMarksControllerDataSource,OpenOverProtocol,MessageViewModelDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    var locationManager = CLLocationManager()
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
    
    let nextButtonText = "好"
    var disposeBag = DisposeBag()
    
    let msg: MessageApi = MessageApi.defaultMessages
    
    
    @IBOutlet weak var addNewButton: AnimatableButton!
    @IBOutlet weak var findMoreButton: AnimatableButton!
    
    @IBOutlet var mapView: MKMapView!
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
            .subscribeNext { [weak self] in self?.searchMsg(jwt.userName) }
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
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
//    @IBAction func deleteMap(sender: AnyObject) {
//        
//        self.mapView.removeAnnotations(mapView.annotations)
//        
//    }
//    
    
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

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //自定义地图图标
//        if annotation is MyAnnotation {
//            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("MYANNOTATION")  as? MKPinAnnotationView
//            if annotationView == nil {
//                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MYANNOTATION")
//                annotationView!.canShowCallout = true
        
//            }
//            else {
//                annotationView!.annotation = annotation
//            }
//            return annotationView
//        }
//        else {
            let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("DEFAULT")  as? MKPinAnnotationView
            return annotationView
//        }

    }
    

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        selectedView = view;
        
        let pin = view.annotation! as! MyAnnotation
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
            detailView.answer.placeholder = "提示：\(pin.answerTip)"
            detailView.msgId = pin.id
            detailView.fromId = pin.id
            detailView.question.text = pin.question
        
        
        view.detailCalloutAccessoryView = detailView
        
    }

    var selectedView: MKAnnotationView?
    
    func searchMsg(sender: AnyObject) {
        viewModel.longitude = self.longitude
        viewModel.latitude = self.latitude
        viewModel.searchMessage(self.to,map: self.mapView, view: self.view)
        self.mapView.removeAnnotations(mapView.annotations)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                
                self.searchMsg(jwt.userName)
            })
        }
        
    }
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if !userDefaults.boolForKey("NEWONESHOW") {
            
            self.coachMarksController!.startOn(self)
            
            userDefaults.setBool(true, forKey: "NEWONESHOW")
            userDefaults.synchronize()
        }
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

