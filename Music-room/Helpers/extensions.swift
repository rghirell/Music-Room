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


extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
//        self.separatorStyle = .singleLine
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


extension UIView {
    
    func fillSuperview() {
        anchor(top: superview?.topAnchor, leading: superview?.leadingAnchor, bottom: superview?.bottomAnchor, trailing: superview?.trailingAnchor)
    }
    
    func anchorSize(to view: UIView) {
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}

