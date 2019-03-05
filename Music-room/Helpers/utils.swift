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
    
    static func alert(style: UIAlertController.Style, title: String?, message: String?, textFields: [UITextField], completion: @escaping ([String]?) -> ()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        for textField in textFields {
            alert.addTextField(configurationHandler: { (theTextField) in
                theTextField.placeholder = textField.placeholder
                theTextField.isSecureTextEntry = textField.isSecureTextEntry
                theTextField.textContentType = textField.textContentType
            })
        }
        
        let textFieldAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            var textFieldsTexts: [String] = []
            if let alertTextFields = alert.textFields {
                for textField in alertTextFields {
                    if let textFieldText = textField.text {
                        textFieldsTexts.append(textFieldText)
                    }
                }
                completion(textFieldsTexts)
            }
        }
        alert.addAction(textFieldAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
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

