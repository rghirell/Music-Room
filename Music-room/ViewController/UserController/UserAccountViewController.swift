
//
//  UserAccountViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/15/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import MapKit


class UserAccountViewController: UIViewController , CLLocationManagerDelegate {

    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    let buttonTest: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Test", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        navigationItem.title = "Account"
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        view.addSubview(buttonTest)
        buttonTest.addTarget(self, action: #selector(test), for: .touchUpInside)
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
        }
        
        NSLayoutConstraint.activate([
            buttonTest.widthAnchor.constraint(equalToConstant: 50),
            buttonTest.heightAnchor.constraint(equalToConstant: 400)])
        
    }
    @objc func test() {
        locManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        print(NSDate().timeIntervalSince1970)
        locManager.stopUpdatingLocation()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
