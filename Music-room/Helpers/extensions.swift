//
//  extensions.swift
//  Music-room
//
//  Created by raphael ghirelli on 1/25/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import Foundation
import UIKit


private var timer: Timer?
extension UIViewController {
    
    class func displaySpinner(onView : UIView) -> UIView {
        let textLabel = UILabel()
        textLabel.font = UIFont.boldSystemFont(ofSize: 16)
        textLabel.text = "Loading ."
        textLabel.textColor = .white
        
       timer =  Timer.scheduledTimer(withTimeInterval: 0.55, repeats: true) { (timer) in
            var string: String {
                switch textLabel.text {
                case "Loading .":       return "Loading .."
                case "Loading ..":      return "Loading ..."
                case "Loading ...":     return "Loading ."
                default:                return "\(textLabel.text!)"
                }
            }
            print("in")
            textLabel.text = string
        }
        
        let container: UIView = UIView.init(frame: onView.bounds)
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8)
        spinnerView.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        spinnerView.center = container.center
    
        spinnerView.clipsToBounds = true
        spinnerView.layer.cornerRadius = 10
        
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.center = CGPoint(x: spinnerView.frame.size.width / 2,
                            y: spinnerView.frame.size.height / 2)
        
        textLabel.frame = CGRect(x: 0, y: 0, width: 80
            ,height: 50)
        textLabel.center =  CGPoint(x: spinnerView.frame.size.width / 2,
                                    y: 100);
        ai.startAnimating()
        
        
        DispatchQueue.main.async {
            spinnerView.addSubview(textLabel)
            spinnerView.addSubview(ai)
            container.addSubview(spinnerView)
            onView.addSubview(container)
        }
        
        return container
    }
    
    class func removeSpinner(spinner :UIView) {
        timer?.invalidate()
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
            
        }
    }
}


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}


extension PlayerViewController {
    func assignBackground(){
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
//        imageView.image = background
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imageView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.addSubview(blurEffectView)
//        imageView.center = view.center
        view.addSubview(imageView)
        view.sendSubviewToBack(imageView)
    }
    
}


extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

