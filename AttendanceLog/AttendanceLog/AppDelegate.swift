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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.setApplicationId("xBguYb7K8F3qt2gEmhzkmLrUnPUv4Nqo3gjUmmd6",
            clientKey: "4FfN0YC7BzxJohPsmS2bNWpuw6IXVq4sDs1WZQoA")
        return true
    }
}

