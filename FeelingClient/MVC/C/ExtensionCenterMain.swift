//
//  ExtensionCenterMain.swift
//  FeelingClient
//
//  Created by Vincent on 16/7/10.
//  Copyright © 2016年 xecoder. All rights reserved.
//

import Foundation


extension CenterMain: ARDataSource {
    func ar(arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView
    {
        // Annotation views should be lightweight views, try to avoid xibs and autolayout all together.
        let annotationView = TestAnnotationView()
        annotationView.frame = CGRect(x: 0,y: 0,width: 200,height: 50)
        return annotationView;
    }
    
    private func getDummyAnnotations() -> Array<ARAnnotation>
    {
        var annotations: [ARAnnotation] = []
        
        for i in 0.stride(to: self.viewModel.annotationArray.count, by: 1) {
            let annotation = ARAnnotation()
            let myAnnotation = self.viewModel.annotationArray[i]
            annotation.location = CLLocation(latitude: myAnnotation.original_coordinate!.latitude, longitude: myAnnotation.original_coordinate!.longitude)
            annotation.imageUrl = myAnnotation.url
            annotation.title = myAnnotation.title
            annotation.id = myAnnotation.id
            annotation.fromId = myAnnotation.fromId
            annotation.msgId = myAnnotation.id
            annotation.question = myAnnotation.question
            annotation.answerTip = myAnnotation.answerTip
            annotations.append(annotation)
        }
        
        return annotations
    }
    
    private func getRandomLocation(centerLatitude centerLatitude: Double, centerLongitude: Double, delta: Double) -> CLLocation
    {
        var lat = centerLatitude
        var lon = centerLongitude
        
        let latDelta = -(delta / 2) + drand48() * delta
        let lonDelta = -(delta / 2) + drand48() * delta
        lat = lat + latDelta
        lon = lon + lonDelta
        return CLLocation(latitude: lat, longitude: lon)
    }
    
    func showARViewController()
    {
        // Check if device has hardware needed for augmented reality
        let result = ARViewController.createCaptureSession()
        if result.error != nil
        {
            let message = result.error?.userInfo["description"] as? String
            let alert = UIAlertController(title: "知道", message: message, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // Create random annotations around center point    //@TODO
        //FIXME: set your initial position here, this is used to generate random POIs
        
        let dummyAnnotations = self.getDummyAnnotations()
        
        // Present ARViewController
        let arViewController = ARViewController()
        arViewController.debugEnabled = true
        arViewController.dataSource = self
        arViewController.maxDistance = 0
        arViewController.maxVisibleAnnotations = 100
        arViewController.maxVerticalLevel = 5
        arViewController.headingSmoothingFactor = 0.05
        arViewController.trackingManager.userDistanceFilter = 25
        arViewController.trackingManager.reloadDistanceFilter = 75
        arViewController.setAnnotations(dummyAnnotations)
        self.presentViewController(arViewController, animated: true, completion: nil)
    }
    
    @IBAction func buttonTap(sender: AnyObject)
    {
        showARViewController()
    }
    
}

