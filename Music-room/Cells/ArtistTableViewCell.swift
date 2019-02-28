//
//  ArtistTableViewCell.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/5/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import SwipeCellKit

fileprivate let imageCache = NSCache<AnyObject, AnyObject>()
class ArtistTableViewCell: SwipeTableViewCell {

     var artist: Artist! {
        didSet {
            artistLabel.text = artist.name
        }
    }
    
    var urlString: String?

    let artistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let artistPlaceholder: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(12)
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = "Artist"

        return label
    }()
    
    let thumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        return imageView
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
    

    func setupLayout() {
        selectionStyle = .none
        viewContainer.layer.cornerRadius = 10
        viewContainer.layer.borderColor = UIColor.black.cgColor
        viewContainer.layer.shadowColor = UIColor.black.cgColor
        viewContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
        viewContainer.layer.shadowOpacity = 0.4
        viewContainer.layer.shadowRadius = 4.0
        
        addSubview(viewContainer)
        viewContainer.addSubview(artistLabel)
        viewContainer.addSubview(artistPlaceholder)
        viewContainer.addSubview(thumbnail)
        viewContainer.addSubview(disclosure)
        
        NSLayoutConstraint.activate([
            viewContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            viewContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            viewContainer.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -24),
            viewContainer.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -20),
            
            thumbnail.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 12),
            thumbnail.heightAnchor.constraint(equalTo: viewContainer.heightAnchor, constant: -24),
            thumbnail.widthAnchor.constraint(equalTo: thumbnail.heightAnchor, multiplier: 1),
            artistLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12),
            artistLabel.trailingAnchor.constraint(equalTo: disclosure.leadingAnchor, constant: -12),
            artistLabel.bottomAnchor.constraint(equalTo: thumbnail.centerYAnchor, constant: -5),
            artistPlaceholder.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12),
            artistPlaceholder.trailingAnchor.constraint(equalTo: disclosure.leadingAnchor, constant: -12),
            artistPlaceholder.topAnchor.constraint(equalTo: thumbnail.centerYAnchor, constant: 5),
            disclosure.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -12),
            disclosure.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor, constant: 0),
            disclosure.heightAnchor.constraint(equalToConstant: 25),
            disclosure.widthAnchor.constraint(equalTo: disclosure.heightAnchor),
            ])
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.thumbnail.layer.masksToBounds = true
        self.thumbnail.layer.cornerRadius = CGFloat(roundf(Float(self.thumbnail.frame.size.width/2.0)))
    }

}
