//
//  AppDelegate.swift
//  howlatthemoon
//
//  Created by Sage Conger on 2/24/19.
//  Copyright © 2019 sageconger. All rights reserved.
//

import UIKit
import SquareReaderSDK

let backgroundViewController = BackgroundViewController()
var playlist : [Song] = []
var searchTerm = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = backgroundViewController
        window?.makeKeyAndVisible()

        let welcomeViewController = WelcomeViewController()
        backgroundViewController.present(welcomeViewController, animated: false)
        
        SQRDReaderSDK.initialize(applicationLaunchOptions: launchOptions)
        authorizeReaderSDKIfNeeded()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func retrieveAuthorizationCode(completion: @escaping(String) -> Void) {
        
        let authenticateString = Square.authorize
        
        var request = URLRequest(url: URL(string: authenticateString)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer EAAAECqkFzwAJ8LbjD6t5YpUm0YTyaiqo3xEnia2crpOOHZkKB3NgGTHJpXKisPG", forHTTPHeaderField: "Authorization")
        request.httpBody = "{\"location_id\":\"1V23QVGQHVS8P\"}".data(using: .utf8)
        
        // Create and run a URLSession data task with our JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let unwrappedData = data else {
                print("Error unwrapping data"); return
            }
            
            do {
                let responseJSON = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as! CategoryJSON
                completion(responseJSON["authorization_code"] as! String)
            }
            catch {
                completion("")
            }
        }
        task.resume()
    }
    
    func authorizeReaderSDKIfNeeded() {
        if SQRDReaderSDK.shared.isAuthorized {
            print("Already authorized.")
        }
        else {
            self.retrieveAuthorizationCode { authCode in
                DispatchQueue.main.async {
                    SQRDReaderSDK.shared.authorize(withCode: authCode) { location, error in
                        if let authError = error {
                            // Handle the error
                            print(authError)
                        }
                        else {
                            print("Authorized!")
                        }
                    }
                }
            }
        }
    }

}

