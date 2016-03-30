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

import IBAnimatable

class OpenMapViewController: UIViewController, OpenMessageModelDelegate , MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var openButton: AnimatableButton!
    var msgModel: OpenMessageModel!
    var latitude = 0.0
    var longitude = 0.0
    
    var isOk = false
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        msgModel = OpenMessageModel(delegate: self)
        
        locationManager.delegate = self
        //locationManager.distanceFilter = 1;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
//        
//        let everythingValid = Observable.combineLatest(questionValid, answerValid) { $0 && $1}
//            .shareReplay(1)
//        
//        
//        everythingValid
//            .bindTo(verifyButton.rx_enabled)
//            .addDisposableTo(disposeBag)
//        
//        
//        verifyButton.rx_tap
//            .subscribeNext { [weak self] in self?.verifyAnswer() }
//            .addDisposableTo(disposeBag)
//
//        
        // Do any additional setup after loading the view.
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
                let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                self.mapView.region = region
                self.isOk = true
            })
        }
        
    }
    

    
    func verifyAnswer()
    {
        
    }
    
    func arrival()
    {
        msgModel.x = self.latitude
        msgModel.y = self.longitude
        msgModel.arrival(self.view)
    }

}
