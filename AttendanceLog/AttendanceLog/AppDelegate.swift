//
//  AppDelegate.swift
//  AttendanceLog
//
//  Created by Luke Madronal on 11/12/15.
//  Copyright © 2015 Luke Madronal. All rights reserved.
//

import UIKit
import Parse
import Bolts
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate {
    
    var window: UIWindow?
    let beaconManager = ESTBeaconManager()
    var lastRegion: CLBeaconRegion?
    
    var lastDateMint :NSDate!
    var lastDateBlue :NSDate!
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.setApplicationId("xBguYb7K8F3qt2gEmhzkmLrUnPUv4Nqo3gjUmmd6",
            clientKey: "4FfN0YC7BzxJohPsmS2bNWpuw6IXVq4sDs1WZQoA")
        self.beaconManager.delegate = self
        checkForLocationAuthorization()
        return true
    }
}

extension AppDelegate {
    
    func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if beacons.count > 0 {
            let nearestBeacon = beacons[0]
            if (region != lastRegion) {
                switch nearestBeacon.proximity {
                case .Immediate:
                    dispatch_async(dispatch_get_main_queue()) {
                        let fiveMinutesAgo = NSDate(timeInterval: -60 * 5, sinceDate: NSDate())
                        if let _ = self.lastDateBlue {
                            
                        } else {
                            self.lastDateBlue = NSDate(timeInterval: -60 * 6, sinceDate: NSDate())
                        }
                        if let _ = self.lastDateMint {
                            
                        } else {
                            self.lastDateMint = NSDate(timeInterval: -60 * 6, sinceDate: NSDate())
                        }
                        if (region.identifier == "MintBeacon" && self.lastDateMint.compare(fiveMinutesAgo) == NSComparisonResult.OrderedAscending) {
                            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "recievedDataFromBlue", object: nil))
                        } else if (region.identifier == "BlueBeacon" && self.lastDateBlue.compare(fiveMinutesAgo) == NSComparisonResult.OrderedAscending) {
                            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "recievedDataFromMint", object: nil))
                        }
                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "recievedDataFromServer", object: nil))
                    }
                    print("Ranged Immediate \(region.identifier) beacon")
                case .Near:
                    print("Ranged near \(region.identifier) beacon")
                case .Far:
                    print("Ranged far \(region.identifier) beacon")
                case .Unknown:
                    print("Ranged unknown \(region.identifier) beacon")
                }
                lastRegion = region
            }
        }
    }
    
    func beaconManager(manager: AnyObject, didDetermineState state: CLRegionState, forRegion region: CLBeaconRegion) {
        switch state {
        case .Unknown:
            print("region \(region.identifier) unknown")
        case .Inside:
            print("inside \(region.identifier) region")
        case.Outside:
            print("outside \(region.identifier) region")
        }
    }
    
    func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        print("did enter region \(region.identifier)")
    }
    
    func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
        print("Did exit \(region.identifier)")
    }
    
    func setUpBeacons() {
        print("setting up beacons")
        let uuidString = "B9407F30-F5F8-466E-AFF9-25556B57FE6D"
        let beaconUUID = NSUUID(UUIDString: uuidString)!
        
        let beaconIdentifier = "Iron Yard"
        let allBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, identifier: beaconIdentifier)
        beaconManager.startMonitoringForRegion(allBeaconRegion)
        
        //        let beacon1Major: CLBeaconMajorValue = 39380
        //        let beacon1Minor: CLBeaconMinorValue = 44024
        //        let beacon1Identifier = "PurpleBeacon"
        //        let purpleBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, major: beacon1Major, minor: beacon1Minor, identifier: beacon1Identifier)
        //        beaconManager.startRangingBeaconsInRegion(purpleBeaconRegion)
        
        let beacon2Major: CLBeaconMajorValue = 31640
        let beacon2Minor: CLBeaconMinorValue = 65404
        let beacon2Identifier = "BlueBeacon"
        let blueBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, major: beacon2Major, minor: beacon2Minor, identifier: beacon2Identifier)
        beaconManager.startRangingBeaconsInRegion(blueBeaconRegion)
        
        let beacon3Major: CLBeaconMajorValue = 34909
        let beacon3Minor: CLBeaconMinorValue = 15660
        let beacon3Identifier = "MintBeacon"
        let mintBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, major: beacon3Major, minor: beacon3Minor, identifier: beacon3Identifier)
        beaconManager.startRangingBeaconsInRegion(mintBeaconRegion)
    }
    
    func checkForLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            print("location services on")
            switch ESTBeaconManager.authorizationStatus() {
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                print("start up")
                setUpBeacons()
            case .Denied,.Restricted:
                print("hey user, turn us on in settings")
            case .NotDetermined:
                print("not determined")
                if beaconManager.respondsToSelector("requestAlwaysAuthorization") {
                    print("Requesting Always")
                    beaconManager.requestAlwaysAuthorization()
                }
            }
        } else {
            print("turn on location services!!")
        }
    }
}


