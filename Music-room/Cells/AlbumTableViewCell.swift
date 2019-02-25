//
//  AlbumTableViewCell.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/8/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {
    
    
    
    let albumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let thumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        
        return imageView
    }()

    let albumPlaceholder: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(12)
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = "Album "
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    // MARK: LAyout Setup
    
    fileprivate func setupLayout() {
        addSubview(albumPlaceholder)
        addSubview(albumLabel)
        addSubview(thumbnail)
        
        NSLayoutConstraint.activate([
            thumbnail.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            thumbnail.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -24),
            thumbnail.widthAnchor.constraint(equalTo: thumbnail.heightAnchor, multiplier: 1),
            albumLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12),
            albumLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            albumLabel.topAnchor.constraint(equalTo: thumbnail.topAnchor, constant: 6),
            albumPlaceholder.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12),
            albumPlaceholder.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            albumPlaceholder.bottomAnchor.constraint(equalTo: thumbnail.bottomAnchor, constant: -6),
            ])
    }
    

}
