//
//  TrackTableViewCell.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/8/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

class PlaylistTrackTableViewCell: UITableViewCell {
    
    var urlString: String?
    
    private var showsPlaylist = false
    var trackLabelToThumbnailConstraint: NSLayoutConstraint!
    var trackLabelToViewConstraint: NSLayoutConstraint!
    var delegateViewController: UIViewController?
    var currentTrack: [String: Any]?
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
    
    
    let viewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    let viewPlaylist: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let dragPlaylist: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "moreBlack"), for: .normal)
        return button
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        
        viewPlaylist.layer.cornerRadius = 10
        viewPlaylist.layer.borderColor = UIColor.black.cgColor
        viewPlaylist.layer.shadowColor = UIColor.black.cgColor
        viewPlaylist.layer.shadowOffset = CGSize(width: 3, height: 3)
        viewPlaylist.layer.shadowOpacity = 0.4
        viewPlaylist.layer.shadowRadius = 4.0
        
        viewContainer.layer.cornerRadius = 10
        viewContainer.layer.borderColor = UIColor.black.cgColor
        viewContainer.layer.shadowColor = UIColor.black.cgColor
        viewContainer.layer.shadowOffset = CGSize(width: 3, height: 3)
        viewContainer.layer.shadowOpacity = 0.4
        viewContainer.layer.shadowRadius = 4.0
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        if showsPlaylist {
            viewPlaylist.isHidden = true
            viewContainer.isHidden = false
            showsPlaylist = false
        }
    }
    
    
    @objc func presentPlaylist() {
        UIView.transition(from: viewContainer, to: viewPlaylist, duration: 0.3, options: [.transitionFlipFromBottom, .showHideTransitionViews] , completion: nil)
        showsPlaylist = true
    }
    

    
    func setupLayout() {
        selectionStyle = .none

        addSubview(viewPlaylist)
        addSubview(viewContainer)
        
        viewContainer.addSubview(trackLabel)
        viewContainer.addSubview(trackPlaceholder)
        viewContainer.addSubview(thumbnail)
        viewContainer.addSubview(dragPlaylist)
        
        
        
        trackLabelToThumbnailConstraint = trackLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12)
        trackLabelToViewConstraint = trackLabel.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 12)
        trackLabelToThumbnailConstraint.priority = UILayoutPriority.defaultHigh
        trackLabelToViewConstraint.priority = UILayoutPriority.defaultLow
        
        NSLayoutConstraint.activate([
            viewContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            viewContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            viewContainer.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -24),
            viewContainer.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -20),
            viewPlaylist.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            viewPlaylist.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            viewPlaylist.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -24),
            viewPlaylist.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -20),
            thumbnail.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 12),
            thumbnail.heightAnchor.constraint(equalTo: viewContainer.heightAnchor, constant: -24),
            thumbnail.widthAnchor.constraint(equalTo: thumbnail.heightAnchor, multiplier: 1),
            trackLabelToThumbnailConstraint,
            trackLabelToViewConstraint,
            trackLabel.trailingAnchor.constraint(equalTo:  dragPlaylist.leadingAnchor , constant: -12),
            trackLabel.bottomAnchor.constraint(equalTo: thumbnail.centerYAnchor, constant: -5),
            trackPlaceholder.leadingAnchor.constraint(equalTo: trackLabel.leadingAnchor),
            trackPlaceholder.trailingAnchor.constraint(equalTo: dragPlaylist.leadingAnchor , constant: -12),
            trackPlaceholder.topAnchor.constraint(equalTo: thumbnail.centerYAnchor, constant: 5),
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
