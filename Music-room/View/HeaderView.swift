//
//  HeaderView.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/19/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
    
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
