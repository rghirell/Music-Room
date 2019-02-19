//
//  DetailHeaderView.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/19/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

class DetailHeaderView: UIView
{
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
            } else {
                imageView.image = nil
            }
        }
    }
}
