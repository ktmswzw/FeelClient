//
//  CenterViewController.swift
//  FeelingClient
//
//  Created by vincent on 14/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import IBAnimatable
import MediaPlayer
import MobileCoreServices

import SwiftyJSON
import Alamofire

import ImagePickerSheetController
class CenterViewController: DesignableViewController,MessageViewModelDelegate , MKMapViewDelegate, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var address: AnimatableTextField!
    @IBOutlet var textView: KMPlaceholderTextView!
    var lockDate:String = ""
    @IBOutlet var openUser: UITextField!
    @IBOutlet var question: UITextField!
    @IBOutlet var answer: UITextField!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var photoCollectionView: UICollectionView!
    @IBOutlet var hidden2: UIView!
    @IBOutlet var hidden3: UIView!
    @IBOutlet var hidden4: UIView!
    @IBOutlet var hidden5: UIView!
    
    @IBOutlet var selfImage: UIImageView!
    
    //录音
    var recordIndicatorView: RecordIndicatorView!
    var recorder: AudioRecorderBean!
    @IBOutlet var recordButton: UIButton!
    let indicatorViewH: CGFloat = 120
    var messageList = [Message]()
    
    var player: AudioPlayer!
    var picker = UIImagePickerController()
    var viewModel: MessageViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = MessageViewModel(delegate: self)
        self.openUser.text = viewModel.to
        
        //地图初始化
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 1;
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        self.mapView.showsUserLocation = true
        
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
        
        recordButton.addTarget(self, action: #selector(CenterViewController.recordClick(_:)), forControlEvents: .TouchDown)
                
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(CenterViewController.playAction))
        selfImage.userInteractionEnabled = true
        selfImage.addGestureRecognizer(tapGestureRecognizer)
        selfImage.animationDuration = 1.0
        selfImage.hidden = true;
        
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
    
    
    func stopAnimation() {
        if selfImage.isAnimating() {
            selfImage.stopAnimating()
        }
    }
    
    
    func beginAnimation() {
        selfImage.startAnimating()
    }
    func playAction(sender: AnyObject) {
        setUpVoicePlayIndicatorImageView()
        for message in messageList {
            if message.messageType == .Voice {
                let message = message as! voiceMessage
                
                let play = AudioPlayer()
                player = play
                player.startPlaying(message)
                
                beginAnimation()
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(message.voiceTime.intValue) * 1000 * 1000 * 1000), dispatch_get_main_queue(), { () -> Void in
                    self.stopAnimation()
                })
            } else if message.messageType == .Video {
                
            }
        }
    }

    
    func setUpVoicePlayIndicatorImageView() {
        let images =  NSArray(objects: UIImage(named: "ReceiverVoiceNodePlaying001")!, UIImage(named: "ReceiverVoiceNodePlaying002")!, UIImage(named: "ReceiverVoiceNodePlaying003")!)
            selfImage.image = UIImage(named: "ReceiverVoiceNodePlaying")
        
        selfImage.animationImages = (images as! [UIImage])
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if event?.type == UIEventType.Motion && event?.subtype == UIEventSubtype.MotionShake {
            print("Shake Motion Began :)")
            messageList.removeAll();
            selfImage.hidden = true;
        }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if event?.type == UIEventType.Motion && event?.subtype == UIEventSubtype.MotionShake {
            print("Shake Motion Ended :(")
        }
    }
    
    override func motionCancelled(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if event?.type == UIEventType.Motion && event?.subtype == UIEventSubtype.MotionShake {
            print("Shake Motion Canceled :(")
        }
    }
    
    @IBAction func sendMsg(sender: AnyObject) {
        if !self.address.notEmpty {
            self.view.makeToast("定位中，请开启GPS，或在空旷地带，以精确定位", duration: 2, position: .Center)
            return
        }
        
//        if !self.openUser.notEmpty {
//            self.view.makeToast("开启人必须填写", duration: 2, position: .Center)
//            return
//        }
//        
        if self.textView.text.length == 0 {
            self.view.makeToast("必须填写内容", duration: 2, position: .Center)
            return
        }
        viewModel.to = self.openUser.text!
        viewModel.content = self.textView.text!
        viewModel.question = self.question.text!
        viewModel.answer = self.answer.text!
        viewModel.address = self.address.text!
        self.navigationController?.view.makeToastActivity(.Center)
        viewModel.sendMessage(self)
        
        
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
        
        viewModel.latitude =  location!.coordinate.latitude
        viewModel.longitude = location!.coordinate.longitude
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.mapView.setRegion(region, animated: true)
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {
            (placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
            
            self.locationManager.stopUpdatingLocation()
        })
        
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        //stop updating location to save battery life
        locationManager.stopUpdatingLocation()
        //        print(placemark.locality)
        //        print(placemark.administrativeArea)
        //        print(placemark.country)
        if let locationName = placemark.addressDictionary!["Name"] as? NSString {
            address.text = locationName as String
        }
    }
    
    func presentImagePickerSheet() {
        let presentImagePickerController: UIImagePickerControllerSourceType -> () = { source in
            let controller = UIImagePickerController()
            controller.delegate = self
            var sourceType = source
            if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                sourceType = .PhotoLibrary
                print("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
            }
            controller.sourceType = sourceType
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
        let controller = ImagePickerSheetController(mediaType: .ImageAndVideo)
        controller.addAction(ImagePickerAction(title: NSLocalizedString("拍摄", comment: "标题"),handler: { _ in
            presentImagePickerController(.Camera)
            }, secondaryHandler: { _, numberOfPhotos in
                for ass in controller.selectedImageAssets
                {
                    let image = getAssetThumbnail(ass)
                    self.viewModel.imageDataThumbnail.append(image)
                    let imageOr = getImageFromPHAsset(ass)
                    self.viewModel.imageData.append(imageOr)
                }
                self.photoCollectionView.reloadData()
        }))
        controller.addAction(ImagePickerAction(title: NSLocalizedString("相册", comment: "标题"), secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "Action Title"), $0) as String}, handler: { _ in
            presentImagePickerController(.PhotoLibrary)
            }, secondaryHandler: { _, numberOfPhotos in
                //print("Send \(controller.selectedImageAssets)")
                for ass in controller.selectedImageAssets
                {
                    let image = getAssetThumbnail(ass)
                    self.viewModel.imageDataThumbnail.append(image)
                    let imageOr = getImageFromPHAsset(ass)
                    self.viewModel.imageData.append(imageOr)
                }
                self.photoCollectionView.reloadData()
                
        }))
        controller.addAction(ImagePickerAction(title: NSLocalizedString("取消", comment: "Action Title"), style: .Cancel, handler: { _ in
            //print("Cancelled")
        }))
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            controller.modalPresentationStyle = .Popover
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.sourceRect = CGRect(origin: view.center, size: CGSize())
        }
        
        presentViewController(controller, animated: true, completion: nil)
    }
}



extension CenterViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.imageDataThumbnail.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case self.viewModel.imageDataThumbnail.count:
            presentImagePickerSheet()
        default:
            self.viewModel.imageDataThumbnail.removeAtIndex(indexPath.row)
            photoCollectionView.reloadData()
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        switch indexPath.row {
            
        case self.viewModel.imageDataThumbnail.count:
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("newCell", forIndexPath: indexPath)
        default:
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("photo", forIndexPath: indexPath)
            let imgV = UIImageView(image: self.viewModel.imageDataThumbnail[indexPath.row])
            imgV.frame = cell.frame
            cell.backgroundView = imgV
            cell.layer.cornerRadius = 5
        }
        
        
        return cell
    }
}

extension CenterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.viewModel.imageDataThumbnail.append(image)
        photoCollectionView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CenterViewController: AudioRecorderDelegate {
    
    func recordClick(button: UIButton) {
        self.title = "松开     结束"
        button.addTarget(self, action: #selector(CenterViewController.recordComplection(_:)), forControlEvents: .TouchUpInside)
        button.addTarget(self, action: #selector(CenterViewController.recordDragOut(_:)), forControlEvents: .TouchDragOutside)
        button.addTarget(self, action: #selector(CenterViewController.recordCancel(_:)), forControlEvents: .TouchUpOutside)
        
        let currentTime = NSDate().timeIntervalSinceReferenceDate
        let record = AudioRecorderBean(fileName: "\(currentTime).wav")
        record.delegate = self
        recorder = record
        recorder.startRecord()
        
        recordIndicatorView = RecordIndicatorView(frame: CGRectMake(self.view.center.x - indicatorViewH / 2, self.view.center.y - indicatorViewH / 3, indicatorViewH, indicatorViewH))
        view.addSubview(recordIndicatorView)
    }
    
    func recordComplection(button: UIButton) {
        self.title = "按住     说话"
        recorder.stopRecord()
        recorder.delegate = nil
        recordIndicatorView.removeFromSuperview()
        recordIndicatorView = nil
        
        if recorder.timeInterval != nil {
            let message = voiceMessage(incoming: false, sentDate: NSDate(), iconName: "", voicePath: recorder.recorder.url, voiceTime: recorder.timeInterval)
            //let receiveMessage = voiceMessage(incoming: true, sentDate: NSDate(), iconName: "", voicePath: recorder.recorder.url, voiceTime: recorder.timeInterval)
            
            self.title = ""
            selfImage.hidden = false;
            messageList.append(message)
            //messageList.append(receiveMessage)
            
        }
    }
    
    func recordDragOut(button: UIButton) {
        self.title = "按住     说话"
        recordIndicatorView.showText("松开手指,取消发送", textColor: UIColor.redColor())
    }
    
    
    func recordCancel(button: UIButton) {
        self.title = "按住     说话"
        recorder.stopRecord()
        recorder.delegate = nil
        recordIndicatorView.removeFromSuperview()
        recordIndicatorView = nil
    }
    
    
    // MARK: -LGrecordDelegate
    func audioRecorderUpdateMetra(metra: Float) {
        if recordIndicatorView != nil {
            recordIndicatorView.updateLevelMetra(metra)
        }
    }
}

