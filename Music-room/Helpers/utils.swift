//
//  utils.swift
//  Music-room
//
//  Created by raphael ghirelli on 1/25/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase

struct Alert {
    static func errorAlert(title: String, message: String?, cancelButton: Bool = false, completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) {
            _ in
            guard let completion = completion else { return }
            completion()
        }
        alert.addAction(actionOK)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if cancelButton { alert.addAction(cancel) }
        return alert
    }
}

struct jsonHelper {
    static func convertJSONToObject(data: Data?) -> [String: AnyObject]? {
        do {
            let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
            return result
            
        } catch {
            print("Error -> \(error)")
        }
        return nil
    }
}

