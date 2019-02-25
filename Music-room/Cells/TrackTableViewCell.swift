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
    
    let addToPlaylistButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "moreBlack"), for: .normal)
        return button 
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func presentPlaylist() {
        let vc = AddToPlaylistTableViewController()
        let nc = UINavigationController(rootViewController: vc)
        let alert = UIAlertController(title: "Add to Playlist", message: "Choose which kind of playlist you want to add your song to", preferredStyle: .actionSheet)
        let eventAction = UIAlertAction(title: "Add to event playlist", style: .default) { (action) in
            vc.isRegularPlaylist = false
            vc.track = self.currentTrack
            self.delegateViewController?.present(nc, animated: true, completion: nil)
        }
        let playlistAction = UIAlertAction(title: "Add to my playlist", style: .default) { (action) in
            vc.isEventPlaylist = false
            vc.track = self.currentTrack
            self.delegateViewController?.present(nc, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(eventAction)
        alert.addAction(playlistAction)
        delegateViewController?.present(alert, animated: true, completion: nil)
    }
    
    func setupLayout() {
        selectionStyle = .none
        
        addSubview(addToPlaylistButton)
        addSubview(trackLabel)
        addSubview(trackPlaceholder)
        addSubview(thumbnail)
        
        addToPlaylistButton.addTarget(self, action: #selector(presentPlaylist), for: .touchUpInside)
        
        trackLabelToThumbnailConstraint = trackLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12)
        trackLabelToViewConstraint = trackLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12)
        trackLabelToThumbnailConstraint.priority = UILayoutPriority.defaultHigh
        trackLabelToViewConstraint.priority = UILayoutPriority.defaultLow
        
        NSLayoutConstraint.activate([
            thumbnail.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            thumbnail.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -24),
            thumbnail.widthAnchor.constraint(equalTo: thumbnail.heightAnchor, multiplier: 1),
            addToPlaylistButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            addToPlaylistButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            addToPlaylistButton.heightAnchor.constraint(equalToConstant: 25),
            addToPlaylistButton.widthAnchor.constraint(equalTo: addToPlaylistButton.heightAnchor),
            trackLabelToThumbnailConstraint,
            trackLabelToViewConstraint,
            trackLabel.trailingAnchor.constraint(equalTo:  addToPlaylistButton.leadingAnchor , constant: -12),
            trackLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
            trackPlaceholder.leadingAnchor.constraint(equalTo: trackLabel.leadingAnchor),
            trackPlaceholder.trailingAnchor.constraint(equalTo: addToPlaylistButton.leadingAnchor , constant: -12),
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
