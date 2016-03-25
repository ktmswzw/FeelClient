//
//  MapHelper.swift
//  FeelingClient
//
//  Created by Vincent on 16/3/25.
//  Copyright © 2016年 xecoder. All rights reserved.
//


import Foundation
import MapKit

let a = 6378245.0
let ee = 0.00669342162296594323

// World Geodetic System ==> Mars Geodetic System
func outOfChina(coordinate: CLLocationCoordinate2D) -> Bool {
    if coordinate.longitude < 72.004 || coordinate.longitude > 137.8347 {
        return true
    }
    
    if coordinate.latitude < 0.8293 || coordinate.latitude > 55.8271 {
        return true
    }
    
    return false
}

func transformLat(x: Double, y: Double) -> Double {
    var ret = -100.0 + 2.0 * x + 3.0 * y
    ret += 0.2 * y * y + 0.1 * x * y
    ret += 0.2 * sqrt(abs(x))
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0
    return ret;
}

func transformLon(x: Double, y: Double) -> Double {
    var ret = 300.0 + x + 2.0 * y
    ret += 0.1 * x * x + 0.1 * x * y
    ret += 0.1 * sqrt(abs(x))
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0
    return ret;
}

// 地球坐标系 (WGS-84) -> 火星坐标系 (GCJ-02)
func wgs2gcj(coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    if outOfChina(coordinate) == true {
        return coordinate
    }
    let wgLat = coordinate.latitude
    let wgLon = coordinate.longitude
    var dLat = transformLat(wgLon - 105.0, y: wgLat - 35.0)
    var dLon = transformLon(wgLon - 105.0, y: wgLat - 35.0)
    let radLat = wgLat / 180.0 * M_PI
    var magic = sin(radLat)
    magic = 1 - ee * magic * magic
    let sqrtMagic = sqrt(magic)
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI)
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI)
    return CLLocationCoordinate2DMake(wgLat + dLat, wgLon + dLon)
}

// 地球坐标系 (WGS-84) <- 火星坐标系 (GCJ-02)
func gcj2wgs(coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    if outOfChina(coordinate) == true {
        return coordinate
    }
    let c2 = wgs2gcj(coordinate)
    return CLLocationCoordinate2DMake(2 * coordinate.latitude - c2.latitude, 2 * coordinate.longitude - c2.longitude)
}

extension CLLocationCoordinate2D {
    func toMars() -> CLLocationCoordinate2D {
        return wgs2gcj(self)
    }
}
