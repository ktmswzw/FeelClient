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

import MediaPlayer
import MobileCoreServices
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
    var address = ""
    var photos: [String] = []
    var voiceUrl = ""
    
    @IBOutlet weak var imageCollection: UICollectionView!
    var isOk = false
    let locationManager = CLLocationManager()
    var targetLocation:CLLocation = CLLocation(latitude: 0, longitude: 0) //目标点火星后
    
    var player: AudioPlayer!
    var targetDistanceLocation:CLLocation = CLLocation(latitude: 0, longitude: 0) //目标点原始距离
    var distance = 0.0 //两点距离
    
    @IBOutlet var voiceImage: UIButton!
    let msg: MessageApi = MessageApi.defaultMessages
    
    var addressDict: [String : AnyObject]?
    
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
        self.imageCollection.delegate = self
        self.imageCollection.dataSource = self
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "添加好友", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.save))
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        imageCollection!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "photo")
        
        let oneAnnotation = MyAnnotation()
        oneAnnotation.coordinate = self.targetLocation.coordinate
        mapView.addAnnotation(oneAnnotation)
        
        
        voiceImage.hidden = true;
        
    }
    
    
    @IBAction func playVoice(sender: AnyObject) {
        self.playAction()
    }
    
    
    
    @IBAction func gotoNav(sender: AnyObject) {
        openTransitDirectionsForCoordinates(self.targetLocation.coordinate, addressDictionary: [:])
    }
    
    func openTransitDirectionsForCoordinates(
        coord:CLLocationCoordinate2D,addressDictionary: [String : AnyObject]?) {
        let placemark = MKPlacemark(coordinate: coord, addressDictionary: addressDictionary) // 1
        let mapItem = MKMapItem(placemark: placemark)  // 2
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit]  // 3
        mapItem.openInMapsWithLaunchOptions(launchOptions)  // 4
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.navigationController != nil{
            // 在后台
        }else{
            // 已关闭
            // 触发 deinit
            self.mapView = nil
            self.view = nil
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
                self.distance = getDistinct(currentLocation, targetLocation: self.targetDistanceLocation)
                self.distinctText.text = "距离 \(self.address) 约： \(Int(self.distance)) 米"
                if(self.distance<100){
                    self.isOk = true
                    self.arrival()
                    self.navigationItem.rightBarButtonItem?.enabled = true
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
                if(m.photos.count>0 && m.photos[0].length != 0 ){
                    self.photos =  m.photos
                    self.imageCollection.reloadData()
                }
                self.textView.text = m.content
                if m.sound != ""  {
                    self.voiceUrl = m.sound!
                    self.voiceImage.hidden = false
                }
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
    
    
    func playAction() {
        let url = NSURL(string: voiceUrl)
        downloadFileFromURL(url!)
    }
    
    func downloadFileFromURL(url:NSURL){
        var downloadTask:NSURLSessionDownloadTask
        downloadTask = NSURLSession.sharedSession().downloadTaskWithURL(url, completionHandler: { (URL, response, error) -> Void in
            self.play(URL!)
        })
        downloadTask.resume()
    }
    
    func play(url:NSURL) {
        do {
            let player2 = try AVAudioPlayer(contentsOfURL: url)
            
            
            let message = voiceMessage(incoming: false, sentDate: NSDate(), iconName: "", voicePath: player2.url!, voiceTime: player2.duration)
            
            if message.messageType == .Voice {
                let play = AudioPlayer()
                player = play
                player.startPlaying(message)
            }
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
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
