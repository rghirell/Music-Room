//
//  TrackTableViewCell.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/8/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {
    
    var urlString: String?
    
    let trackLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let trackPlaceholder: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(12)
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = "Title "
        
        return label
    }()
    
    let thumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        
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
        
        addSubview(trackLabel)
        addSubview(trackPlaceholder)
        addSubview(thumbnail)
        
        NSLayoutConstraint.activate([
            thumbnail.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            thumbnail.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -24),
            thumbnail.widthAnchor.constraint(equalTo: thumbnail.heightAnchor, multiplier: 1),
            trackLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12),
            trackLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            trackLabel.topAnchor.constraint(equalTo: thumbnail.topAnchor, constant: 6),
            trackPlaceholder.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12),
            trackPlaceholder.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            trackPlaceholder.bottomAnchor.constraint(equalTo: thumbnail.bottomAnchor, constant: -6),
            ])
    }

}
