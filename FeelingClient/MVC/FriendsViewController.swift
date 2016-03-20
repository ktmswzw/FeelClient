//
//  FriendsViewController.swift
//  FeelingClient
//
//  Created by vincent on 16/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import UIKit

import MapKit

class FriendsViewController: UIViewController, MKMapViewDelegate   {
    
    @IBOutlet var mapView: MKMapView!
    
    
    override func viewDidAppear(animated: Bool) {
        moveToSeoul()
    }
    
    func moveToSeoul() {
        let center = CLLocationCoordinate2DMake(37.551403, 126.988045)
        let span = MKCoordinateSpanMake(0.2, 0.2)
        let region = MKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
