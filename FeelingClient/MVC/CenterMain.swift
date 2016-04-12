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

class CenterMain: UIViewController,MessageViewModelDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    let locationManager = CLLocationManager()
    var latitude = 0.0
    var longitude = 0.0
    var msgId = ""
    var to = ""
    var isOk = false
    var viewModel: MessageViewModel!
    let cache = Shared.imageCache
    
    var disposeBag = DisposeBag()
    
    
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
        self.view.makeToast("定位中", duration: 2, position: .Center)
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    
    //这样将避免约束错误
    override func viewDidAppear(animated: Bool) {
        //self.sendButton.enabled = false
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MyAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("MYANNOTATION")  as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MYANNOTATION")
                annotationView!.canShowCallout = true
                if annotationView!.rightCalloutAccessoryView == nil {
                    let button = UIButton(type: .InfoLight)
                    button.userInteractionEnabled = false
                    annotationView!.rightCalloutAccessoryView = button
                    annotationView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CenterMain.didSelectAnnotationView(_:))))
                }
                let leftIconView = UIImageView(frame: CGRectMake(0, 0, 53, 53))
                if let pin = annotation as? MyAnnotation {
                    if let url:String = pin.url! as String {
                        let URL = NSURL(string: url)!
                        let fetcher = NetworkFetcher<UIImage>(URL: URL)
                        cache.fetch(fetcher: fetcher).onSuccess { image in
                            leftIconView.image = image
                        }
                    }
                }
                else{
                    leftIconView.image = UIImage(named: "girl")
                }
                annotationView!.leftCalloutAccessoryView = leftIconView
                annotationView!.pinTintColor = UIColor.redColor()
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        print("点击注释视图按钮")
        
        selectedView = view;
        
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("点击大头针注释视图")
        selectedView = view;
    }
    
    
    func didSelectAnnotationView(sender: UITapGestureRecognizer) {
        guard let pinView = sender.view as? MKAnnotationView else {
            return
        }
        
        // Show Safari if pinView == selectedView and has a valid HTTP URL string
        if pinView == selectedView {
            let pin = pinView.annotation! as! MyAnnotation
            viewModel.msgId = pin.id as String
            //TODO
            if let q:String = pin.subtitle  {
                viewModel.question = q
            }
            if let t:String = pin.title {
                viewModel.to = t
            }
            if let id:String = pin.fromId {
                viewModel.fromId = id
            }
            
            self.performSegueWithIdentifier("open", sender: self)
        }
    }
    
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
            //bottomBar.navigationItem.hidesBackButton = true
        }
        else if segue.identifier == "open" {
            let viewController = segue.destinationViewController as! OpenMessageViewController
            viewController.viewModel = self.viewModel
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
            })
        }
        
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }
    
    
}
