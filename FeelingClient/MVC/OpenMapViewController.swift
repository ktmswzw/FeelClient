//
//  OpenMapViewController.swift
//  FeelingClient
//
//  Created by Vincent on 16/3/31.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import IBAnimatable
import MobileCoreServices
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif


class OpenMapViewController: UIViewController, OpenMessageModelDelegate , MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var distinctText: AnimatableTextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var openButton: AnimatableButton!
    var msgModel: OpenMessageModel!
    var disposeBag = DisposeBag()
    var latitude = 0.0
    var longitude = 0.0
    
    var isOk = false
    let locationManager = CLLocationManager()
    var targetLocation:CLLocation = CLLocation(latitude: 0, longitude: 0) //目标点
    var distance = 0.0 //两点距离
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //msgModel = OpenMessageModel(delegate: self)
        locationManager.delegate = self
        //locationManager.distanceFilter = 1;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        
        
        let everythingValid = distinctText.rx_text
            .map { (Double($0) ?? 0.0 ) > 100 }
            .shareReplay(1)
        
        
        everythingValid
            .bindTo(openButton.rx_enabled)
            .addDisposableTo(disposeBag)
        
        openButton.rx_tap
            .subscribeNext { [weak self] in self?.arrival() }
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
        latitude =  location!.coordinate.latitude
        longitude = location!.coordinate.longitude
        
        
        if(!isOk){
            UIView.animateWithDuration(1.5, animations: { () -> Void in
                let center = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                self.mapView.region = region
                
                let currentLocation =  CLLocation(latitude: self.latitude, longitude: self.longitude)
                
                self.distance = getDistinct(currentLocation, targetLocation: self.targetLocation)
                self.distinctText.text = "\(self.distance)"
                if(self.distance<100){
                self.isOk = true
                }
            })
        }
        
    }
    
    func verifyAnswer()
    {
        
    }
    
    func arrival()
    {
        msgModel.arrival(self.view);
    }

}
