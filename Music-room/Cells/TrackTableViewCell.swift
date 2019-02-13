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
    var trackLabelToThumbnailConstraint: NSLayoutConstraint!
    var trackLabelToViewConstraint: NSLayoutConstraint!
    
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
        
        trackLabelToThumbnailConstraint = trackLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12)
        trackLabelToViewConstraint = trackLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12)
        trackLabelToThumbnailConstraint.priority = UILayoutPriority.defaultHigh
        trackLabelToViewConstraint.priority = UILayoutPriority.defaultLow
        
        NSLayoutConstraint.activate([
            thumbnail.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            thumbnail.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -24),
            thumbnail.widthAnchor.constraint(equalTo: thumbnail.heightAnchor, multiplier: 1),
            trackLabelToThumbnailConstraint,
            trackLabelToViewConstraint,
            trackLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            trackLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
            trackPlaceholder.leadingAnchor.constraint(equalTo: trackLabel.leadingAnchor),
            trackPlaceholder.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            trackPlaceholder.topAnchor.constraint(equalTo: trackLabel.bottomAnchor, constant: 10),
            
            ])
    }
    
    func hideImageView(isHidden: Bool = false) {
        if (isHidden) {
            trackLabelToThumbnailConstraint.priority = UILayoutPriority.defaultLow
            trackLabelToViewConstraint.priority = UILayoutPriority.defaultHigh
            thumbnail.isHidden = true
        } else {
            trackLabelToThumbnailConstraint.priority = UILayoutPriority.defaultHigh
            trackLabelToViewConstraint.priority = UILayoutPriority.defaultLow
            thumbnail.isHidden = false
        }
    }

}
