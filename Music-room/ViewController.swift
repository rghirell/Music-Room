//
//  ViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 1/25/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        print(Auth.auth().currentUser?.email, Auth.auth().currentUser!.isEmailVerified)
//        checkUser()
       
        print("ViewDidload")
//        Auth.auth().createUser(withEmail: "rghirell@student.42.fr", password: "Lolilol971") { (AuthDataResult, err) in
//            print("hello")
//            print(AuthDataResult?.additionalUserInfo)
//            print(err)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewWillAppear")
//       checkUser()
    }
    
    func checkUser() {
        Auth.auth().currentUser?.reload(completion: { (err) in
            print("reloaded")
            if err != nil {
                print(err?.localizedDescription)
            } else {
                if (Auth.auth().currentUser != nil && Auth.auth().currentUser!.isEmailVerified) {
                   
                }
            }
        })

    }

 


}

