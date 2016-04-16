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
    //    @IBOutlet weak var openButton: AnimatableButton!
    var msgscrentId = ""
    var fromId:String = ""
    var friendModel: FriendViewModel!
    var disposeBag = DisposeBag()
    var latitude = 0.0
    var longitude = 0.0
    
    var photos: [String] = []

    @IBOutlet weak var imageCollection: UICollectionView!
    var isOk = false
    let locationManager = CLLocationManager()
    var targetLocation:CLLocation = CLLocation(latitude: 0, longitude: 0) //目标点
    var distance = 0.0 //两点距离
    
    let msg: MessageApi = MessageApi.defaultMessages
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        friendModel = FriendViewModel(delegate: self)
        locationManager.delegate = self
        //locationManager.distanceFilter = 1;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        sleep(1)
        self.imageCollection.delegate = self
        self.imageCollection.dataSource = self
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "添加好友", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.save))
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        imageCollection!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "photo")
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
                self.distinctText.text = "距离开启地点约： \(Int(self.distance)) 米"
                if(self.distance<100){
                    self.isOk = true
                    self.arrival()
                    self.distinctText.text = "已开启"
                }
            })
        }
        
    }
    
    
    func arrival()
    {
        
        msg.arrival(self.msgscrentId) { (r:BaseApi.Result) -> Void in
            switch (r) {
            case .Success(let r):
                let m = r as! MessagesSecret
                if(m.photos.count>0){
                    self.photos =  m.photos
                }
                self.imageCollection.reloadData()
                
                break;
            case .Failure(let msg):
                self.view.makeToast(msg as! String, duration: 1, position: .Center)
                break;
            }
        }
    }
    
    func save(){
        self.navigationController?.view.makeToastActivity(.Center)
        friendModel.save(self.fromId) { (r:BaseApi.Result) in
            switch (r) {
            case .Success(_):
                self.navigationController?.view.hideToastActivity()
                self.view.makeToast("添加成功", duration: 1, position: .Center)
                self.navigationItem.rightBarButtonItem?.enabled = false
                self.performSegueWithIdentifier("homeMain", sender: self)
                break
            case .Failure(let error):                
                self.navigationController?.view.hideToastActivity()
                self.view.makeToast("添加失败:\(error)", duration: 1, position: .Center)
                break
            }
        }
    }
}


extension OpenMapViewController: FriendModelDelegate{
    
}


extension OpenMapViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewBigImages(self.photos[indexPath.row] )
    }
    
    func viewBigImages(url: String)
    {
        self.performSegueWithIdentifier("showImage", sender: url)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let CellIdentifier = "photo"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        let URLString = self.photos[indexPath.row]
        let URL = NSURL(string:getPathSmall(URLString))!
        cell.imageView.hnk_setImageFromURL(URL)
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImage" {
            let viewController = segue.destinationViewController as! ViewImageViewController
            viewController.imageUrl = getPath(sender as! String)
        }
    }
}
