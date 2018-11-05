//
//  AppDelegate.swift
//  LXFProtocolTool
//
//  Created by LinXunFeng on 04/06/2018.
//  Copyright (c) 2018 LinXunFeng. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIApplication.shared.lxf.currentVcOrientationMask
    }
}

