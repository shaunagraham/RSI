//
//  AppDelegate.swift
//  RapSheet
//
//  Created by Kalpesh Satasiya on 07/08/18.
//  Copyright © 2018 Kalpesh Satasiya. All rights reserved.
//

import UIKit
import AFNetworking
import SwiftyJSON
import Fabric
import Crashlytics
import AdSupport
import KeychainAccess
import GoogleMobileAds


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let keychain = Keychain(service: "com.adrapsheet.crawlapps")
    var issearch = Bool()
    var strval = String()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        28970247-0C2F-43CC-B654-F3E28169489B
        GADMobileAds.configure(withApplicationID: API.UNIT_AD_ID)
        Fabric.with([Crashlytics.self])
        
        if defaults.bool(forKey: "isLaunchFirstTime") {
            defaults.set(false, forKey: "isAppAlreadyLaunchedOnce")
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            defaults.set(true, forKey: "isLaunchFirstTime")
        }
        
                
//        isAppAlreadyLaunchedOnce()
        
        if !isUserLogin() {
            
            let token = try? keychain.get("deviceId")
            print("TOKEN:- \(token ?? "")")
            
            if let token = try? self.keychain.get("deviceId") {
                callUserLoginApi(UDID: token)
            }else{
                callUserLoginApi(UDID: UIDevice.current.identifierForVendor!.uuidString)
            }
            
           
        }
        return true
    }

    //MARK: User Resiter Api Call
    
    func callUserLoginApi(UDID:String) {
        
        let param = [kUUID : UDID]
        
        let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.post(API.ADD_USER, parameters: param, progress: nil, success: { (task: URLSessionDataTask, responseObject: Any?) in
            if let jsonResponse = responseObject as? NSDictionary {
                // here read response
               
                let dictData = JSON(jsonResponse)
                
                let dictUserDetail = dictData["info"]
//                print(dictUserDetail)
                
                if let token = try? self.keychain.get("deviceId") {
                    print(token)
                }else{
                    self.keychain["deviceId"] = UIDevice.current.identifierForVendor!.uuidString
                }
                
                defaults.setValue(dictUserDetail.object, forKey: "isUserLogin")
                defaults.synchronize()
                
                print("login user data:-\(defaults.value(forKey: "isUserLogin") ?? "")")
                
            }
            
        }) { (task: URLSessionDataTask?, error: Error) in
            
            print(error.localizedDescription)
            let errResponse: String = String(data: (error._userInfo![AFNetworkingOperationFailingURLResponseDataErrorKey] as! Data), encoding: String.Encoding.utf8)!
            let dict = errResponse.toDictionary()
            print(dict)
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        defaults.set(false, forKey: "isAppAlreadyLaunchedOnce")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//        defaults.set(false, forKey: "isAppAlreadyLaunchedOnce")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func isAppAlreadyLaunchedOnce()->Bool{
        
        if defaults.bool(forKey: "isAppAlreadyLaunchedOnce") {
            return true
        }else {
            return false
        }
    }

    
}

