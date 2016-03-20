//
//  CustomAnnotation.swift
//  FeelingClient
//
//  Created by vincent on 14/3/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation
import MapKit


class MuseumInfo : MKPointAnnotation {
    var exhibitions : [String]?
    var url : String?
}


class MyAnnotation: MKPointAnnotation {
    var id = ""
}
