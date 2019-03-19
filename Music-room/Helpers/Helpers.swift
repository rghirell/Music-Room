//
//  SparkService.swift
//  TestingFirestoreAuth
//
//  Created by Alex Nagy on 29/11/2018.
//  Copyright © 2018 Alex Nagy. All rights reserved.
//

import UIKit
import JGProgressHUD

class Helpers {
    // MARK: -
    // MARK: dismiss hud
    static func dismissHud(_ hud: JGProgressHUD, text: String, detailText: String, delay: TimeInterval) {
        DispatchQueue.main.async {
            hud.textLabel.text = text
            hud.detailTextLabel.text = detailText
            hud.dismiss(afterDelay: delay, animated: true)
        }
    }
}

struct SparkKeys {
    
    struct CollectionPath {
        static let users = "users"
    }
    
    struct StorageFolder {
        static let profileImages = "profileImages"
    }
}
