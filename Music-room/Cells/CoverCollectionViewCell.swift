//
//  CoverCollectionViewCell.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/9/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

class CoverCollectionViewCell: UICollectionViewCell {
    
    let coverCollectionView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.layer.masksToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    func setupLayout() {
        addSubview(coverCollectionView)
        
        NSLayoutConstraint.activate([
            coverCollectionView.heightAnchor.constraint(equalTo: self.heightAnchor),
            coverCollectionView.widthAnchor.constraint(equalTo: self.heightAnchor),
            coverCollectionView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            coverCollectionView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        coverCollectionView.layer.masksToBounds = true
        coverCollectionView.layer.cornerRadius = 8
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NOT GOOD")
    }
}
