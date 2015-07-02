//
//  BeaconManager.swift
//  HomeBeacon
//
//  Created by miyamotoshota on 2015/07/02.
//  Copyright (c) 2015年 sururne. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconManager:NSObject, CLLocationManagerDelegate {
  /// ビーコンの射程範囲内か
  private var beaconRangeInside :Bool =  false
  /// 前回の相対距離
  private var beforeProximity: CLProximity?
  
  private static let beaconUUID = NSUUID(UUIDString:Config.Uuid.load())
  private let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, identifier: NSBundle.mainBundle().bundleIdentifier)
  private let locationManager = CLLocationManager()
  
  class var instance: BeaconManager {
    struct Manager {
      static let instance: BeaconManager = BeaconManager()
    }
    return Manager.instance
  }
  
  func startMoniter() {
    if(CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)) {
      self.locationManager.delegate = self
      self.beaconRegion.notifyOnEntry = true
      self.beaconRegion.notifyOnExit = true
      self.beaconRegion.notifyEntryStateOnDisplay = false
      
      let appStatus = UIApplication.sharedApplication().applicationState
      let isBackground = appStatus == .Background || appStatus == .Inactive
      if isBackground {
        self.locationManager.startUpdatingLocation()
      }
      
      self.locationManager.startMonitoringForRegion(self.beaconRegion)
    }
  }
  
  // 認証を依頼
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == .NotDetermined {
      self.locationManager.requestAlwaysAuthorization()
    }
  }
  
  func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
    sendLocalNotificationWithMessage("Enter")
    manager.startRangingBeaconsInRegion(beaconRegion)
  }
  
  func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
    sendLocalNotificationWithMessage("Exit")
    manager.startRangingBeaconsInRegion(beaconRegion)
  }
//  // region内にすでにいる場合に備えて、必ずregionについての状態を知らせてくれるように要求する必要がある
//  // このリクエストは非同期で行われ、結果は locationManager:didDetermineState:forRegion: で呼ばれる
//  func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
//    manager.requestStateForRegion(region)
//  }
  
  
  // iBeaconの範囲内にいるのかいないのかが通知される
  // いる場合はレンジングを開始する。
  func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
    switch state {
    case .Inside:
      if region is CLBeaconRegion && CLLocationManager.isRangingAvailable() {
        manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
      }
    default:
      break
    }
  }
  
  // iBeaconの範囲内にいる場合に1秒間隔で呼ばれ、iBeaconの情報を取得できる。
  func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
    println(beacons)
    
    if(beacons.count == 0) { return }
    //複数あった場合は一番先頭のものを処理する
    var beacon = beacons[0] as! CLBeacon
    
    if (beforeProximity == beacon.proximity) {
      return
    }
    beforeProximity = beacon.proximity
    
    /*
    beaconから取得できるデータ
    proximityUUID   :   regionの識別子
    major           :   識別子１
    minor           :   識別子２
    proximity       :   相対距離
    accuracy        :   精度
    rssi            :   電波強度
    */
    if (beacon.proximity == CLProximity.Unknown) {
      self.beaconRangeInside = false
      sendLocalNotificationWithMessage("Unknown")
    } else if !beaconRangeInside {
      self.beaconRangeInside = true
      sendLocalNotificationWithMessage("Immediate")
    }
    
      
  }
  
  func sendLocalNotificationWithMessage(message: String!) {
    let notification:UILocalNotification = UILocalNotification()
    notification.alertBody = message
    
    UIApplication.sharedApplication().scheduleLocalNotification(notification)
  }
}