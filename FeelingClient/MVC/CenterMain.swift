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

import IBAnimatable

class CenterMain: UIViewController,MessageViewModelDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var latitude = 0.0
    var longitude = 0.0
    var isOk = false
    var viewModel: MessageViewModel!
    @IBOutlet var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //地图初始化
        locationManager.delegate = self
        //locationManager.distanceFilter = 1;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        self.mapView.delegate = self
        //self.mapView.showsUserLocation = true
        viewModel = MessageViewModel(delegate: self)
        
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    func sendMessage(){}
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("DEFAULT")  as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DEFAULT")
            //            annotationView!.image = UIImage(named: "qq")
            annotationView!.canShowCallout = true
            if annotationView!.rightCalloutAccessoryView == nil {
                let button = UIButton(type: .InfoLight)
                button.userInteractionEnabled = false
                annotationView!.rightCalloutAccessoryView = button
                annotationView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didSelectAnnotationView:"))
            }
            
            
            let leftIconView = UIImageView(frame: CGRectMake(0, 0, 53, 53))
            leftIconView.image = UIImage(named: "girl")
            annotationView!.leftCalloutAccessoryView = leftIconView
            
            annotationView!.pinTintColor = UIColor.redColor()
            
        }
        else {
            annotationView!.annotation = annotation
        }
        return annotationView
        
        
    }
    
    
    func mapViewWillStartLocatingUser(mapView: MKMapView) {
        print("正在跟踪用户的位置")
    }
    
    func mapViewDidStopLocatingUser(mapView: MKMapView) {
        print("停止跟踪用户的位置")
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        print("更新用户的位置")
    }
    
    func mapView(mapView: MKMapView, didFailToLocateUserWithError error: NSError) {
        print("跟踪用户的位置失败")
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
            
            let title = pin.title! as String
            NSLog(title)
            let id = pin.id as String
            NSLog(id)
            
            
            self.performSegueWithIdentifier("open", sender: self)
            
        }
    }
    
    
    var selectedView: MKAnnotationView?
    
    @IBAction func searchMsg(sender: AnyObject) {
        
        searchMessage()
    }
    
    func searchMessage(){
        viewModel.longitude = self.longitude
        viewModel.latitude = self.latitude
        viewModel.searchMessage(self.mapView)    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "send"{
            let bottomBar = segue.destinationViewController as! CenterViewController
            bottomBar.hidesBottomBarWhenPushed = true
            //bottomBar.navigationItem.hidesBackButton = true
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
