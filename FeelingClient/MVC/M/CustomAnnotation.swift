//
//  CustomAnnotation.swift
//  FeelingClient
//
//  Created by vincent on 14/3/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation
import MapKit

class MyAnnotation: MKPointAnnotation {
    var id = ""
    var url : String?
    var fromId : String?
    var question :String?
    var answerTip: String?
    var original_coordinate: CLLocationCoordinate2D?
}
