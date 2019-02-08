//
//  ArtistTableViewCell.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/5/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit



fileprivate let imageCache = NSCache<AnyObject, AnyObject>()
class ArtistTableViewCell: UITableViewCell {

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
//        imageView.layer.cornerRadius = imageView.frame.height / 2
        return imageView
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
        
        addSubview(artistLabel)
        addSubview(artistPlaceholder)
        addSubview(thumbnail)
        
        NSLayoutConstraint.activate([
            thumbnail.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            thumbnail.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -24),
            thumbnail.widthAnchor.constraint(equalTo: thumbnail.heightAnchor, multiplier: 1),
            artistLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12),
            artistLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            artistLabel.topAnchor.constraint(equalTo: thumbnail.topAnchor, constant: 6),
            artistPlaceholder.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12),
            artistPlaceholder.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            artistPlaceholder.bottomAnchor.constraint(equalTo: thumbnail.bottomAnchor, constant: -6),
            ])
    }

}
