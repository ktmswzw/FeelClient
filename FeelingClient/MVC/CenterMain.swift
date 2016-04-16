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

import Haneke
import IBAnimatable
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class CenterMain: UIViewController,OpenOverProtocol,MessageViewModelDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    var locationManager = CLLocationManager()
    var latitude = 0.0
    var longitude = 0.0
    var msgId = ""
    var to = ""
    var isOk = false
    var msgscrentId = ""
    var viewModel: MessageViewModel!
    let cache = Shared.imageCache
    
    var disposeBag = DisposeBag()
    
    let msg: MessageApi = MessageApi.defaultMessages
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MessageViewModel(delegate: self)
        //地图初始化
        
        //地图初始化
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 1;
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true

        
        

        
        self.mapView.delegate = self
        
        self.searchBar.rx_text
            .debounce(1, scheduler: MainScheduler.asyncInstance)
            .subscribeNext { searchText in
                self.to = searchText
                if self.isOk == true {
                    self.searchMsg(searchText)
                    self.searchBar.endEditing(true)
                }
            }
            .addDisposableTo(disposeBag)
        
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
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
        else{
            self.view.makeToast("定位中", duration: 2, position: .Center)
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    
    func openOverSubmit(id:String, answer:String) {        
        
        msg.verifyMsg(id, answer: answer) { (r:BaseApi.Result) in
            switch (r) {
                case .Success(let r):
                    self.msgscrentId = r as! String;
                    self.view.makeToast("验证成功，前往该地100米之内将开启你们的秘密", duration: 1, position: .Center)
                    sleep(1)
                    self.performSegueWithIdentifier("openOver", sender: self)

                    break;
                case .Failure(let msg):
                    self.view.makeToast(msg as! String, duration: 1, position: .Center)
                    break;
                }
        }
    }

    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        if annotation is MyAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("MYANNOTATION")  as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MYANNOTATION")
                annotationView!.canShowCallout = true
                let detailView = NSBundle.mainBundle().loadNibNamed("point", owner: self, options: nil)[0] as! PointUIView
                detailView.delegate = self
                
                if let pin = annotation as? MyAnnotation {
                    if let url:String = pin.url! as String {
                        let URL = NSURL(string: url)!
                        let fetcher = NetworkFetcher<UIImage>(URL: URL)
                        cache.fetch(fetcher: fetcher).onSuccess { image in
                            detailView.avator.image = image
                        }
                    }
                    detailView.msgId = pin.id
                    detailView.fromId = pin.id
                    detailView.question.text = pin.question
                }

                annotationView!.detailCalloutAccessoryView = detailView
            }
            else {
                annotationView!.annotation = annotation
            }
            return annotationView
        }
        else {
            let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("DEFAULT")  as? MKPinAnnotationView
            return annotationView
        }
        
        
    }
    

    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        selectedView = view;
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        selectedView = view;
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        selectedView = view;
    }
    
//    
//    func didSelectAnnotationView(sender: UITapGestureRecognizer) {
//        
//        guard let pinView = sender.view as? MKAnnotationView else {
//            return
//        }
//        
//        if pinView == selectedView {
//            self.navigationController?.view.makeToastActivity(.Center)
//            let pin = pinView.annotation! as! MyAnnotation
//            viewModel.msgId = pin.id as String
//            //TODO
//            if let q:String = pin.subtitle  {
//                viewModel.question = q
//            }
//            if let t:String = pin.title {
//                viewModel.to = t
//            }
//            if let id:String = pin.fromId {
//                viewModel.fromId = id
//            }
//            self.performSegueWithIdentifier("open", sender: self)
//        }
//    }
    
    var selectedView: MKAnnotationView?
    
    func searchMsg(sender: AnyObject) {
        viewModel.longitude = self.longitude
        viewModel.latitude = self.latitude
        viewModel.searchMessage(self.to,map: self.mapView, view: self.view)
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
            viewController.targetLocation = CLLocation(latitude: self.viewModel.latitude, longitude: self.viewModel.longitude)
            viewController.fromId = self.viewModel.fromId
            viewController.msgscrentId = self.msgscrentId
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
            })
        }
        
    }
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }
    
}

