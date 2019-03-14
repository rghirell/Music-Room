//
//  TagsCollectionViewCell.swift
//  Music-room
//
//  Created by raphael ghirelli on 3/1/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit


class TagsCollectionViewCell: UICollectionViewCell {
    
    
    var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.bold)
        button.tintColor = .white
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
        button.isUserInteractionEnabled = false
        
        return button
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
        label.text = "+"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var buttonLeading: NSLayoutConstraint!
    var buttonLeadingHidden: NSLayoutConstraint!
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 15
        clipsToBounds = true
        addSubview(label)
        addSubview(button)
        buttonLeading = button.leadingAnchor.constraint(equalTo: label.trailingAnchor)
        buttonLeading.priority = .defaultHigh
        buttonLeadingHidden = button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        buttonLeadingHidden.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalTo:heightAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 15),
            button.heightAnchor.constraint(equalTo: heightAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),

            buttonLeading,
            buttonLeadingHidden,
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
    }
    
    func isHidden(hide: Bool) {
        if hide {
            label.isHidden = true
            buttonLeading.priority = .defaultLow
            buttonLeadingHidden.priority = .defaultHigh
        }
    }
    

        
    required init?(coder aDecoder: NSCoder) {
        fatalError("NOT GOOD")
    }
    
}
