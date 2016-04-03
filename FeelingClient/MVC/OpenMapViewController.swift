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

import Haneke

class OpenMapViewController: UIViewController, OpenMessageModelDelegate , MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var distinctText: AnimatableTextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var openButton: AnimatableButton!
    var msgModel: OpenMessageModel!
    var disposeBag = DisposeBag()
    var latitude = 0.0
    var longitude = 0.0
    
    @IBOutlet weak var imageCollection: UICollectionView!
    var isOk = false
    let locationManager = CLLocationManager()
    var targetLocation:CLLocation = CLLocation(latitude: 0, longitude: 0) //目标点
    var distance = 0.0 //两点距离
    
    @IBOutlet weak var textView: UITextView!
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
        
        self.imageCollection.delegate = self
        self.imageCollection.dataSource = self
        
        imageCollection!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "photo")
        let everythingValid = distinctText.rx_text
            .map { (Double($0) ?? 0.0 ) > 100 }
            .shareReplay(1)
        
        
        everythingValid
            .bindTo(openButton.rx_enabled)
            .addDisposableTo(disposeBag)
        
        openButton.rx_tap
            .subscribeNext { [weak self] in
                self?.arrival()
            }
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
        msgModel.arrival(self.view) { (m:MessagesSecret) in
            self.textView.text = m.content
            if(m.photos.count>0){
                self.msgModel.photos = m.photos
            }            
            self.imageCollection.reloadData()
        }
    }

}



extension OpenMapViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.msgModel.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //pickerImage()
        viewBigImages()
        //self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func viewBigImages()
    {
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let CellIdentifier = "photo"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        let URLString = self.msgModel.photos[indexPath.row]
        let URL = NSURL(string:URLString)!
        cell.imageView.hnk_setImageFromURL(URL)
        return cell
    }
}
