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
    
    let disclosure: UIImageView = {
        let image = UIImageView(image: UIImage(named: "disclosure"))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let viewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
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
        
        viewContainer.layer.cornerRadius = 10
        viewContainer.layer.borderColor = UIColor.black.cgColor
        viewContainer.layer.shadowColor = UIColor.black.cgColor
        viewContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
        viewContainer.layer.shadowOpacity = 0.4
        viewContainer.layer.shadowRadius = 4.0
        addSubview(viewContainer)
        
        viewContainer.addSubview(disclosure)
        viewContainer.addSubview(albumPlaceholder)
        viewContainer.addSubview(albumLabel)
        viewContainer.addSubview(thumbnail)
        
        NSLayoutConstraint.activate([
            viewContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            viewContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            viewContainer.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -24),
            viewContainer.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -20),
            thumbnail.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 12),
            thumbnail.heightAnchor.constraint(equalTo: viewContainer.heightAnchor, constant: -24),
            thumbnail.widthAnchor.constraint(equalTo: thumbnail.heightAnchor, multiplier: 1),
            albumLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12),
            albumLabel.trailingAnchor.constraint(equalTo: disclosure.leadingAnchor, constant: -30),
            albumLabel.bottomAnchor.constraint(equalTo: thumbnail.centerYAnchor, constant: -5),
            albumPlaceholder.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12),
            albumPlaceholder.trailingAnchor.constraint(equalTo: disclosure.leadingAnchor, constant: -30),
            albumPlaceholder.topAnchor.constraint(equalTo: thumbnail.centerYAnchor, constant: 5),
            disclosure.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -12),
            disclosure.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor, constant: 0),
            disclosure.heightAnchor.constraint(equalToConstant: 25),
            disclosure.widthAnchor.constraint(equalTo: disclosure.heightAnchor),
            ])
    }
    

}
