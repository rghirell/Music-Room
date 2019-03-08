//
//  TrackTableViewCell.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/8/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol LikeDelegate: class {
    func updatelikes(track: [String: Any], like: Bool)
}

protocol TrackRequestDelegate: class {
    func getTrack(id: Int, completion: @escaping ([String: Any]?, Error?) -> ())
}


class TrackTableViewCell: SwipeTableViewCell {
    
    var urlString: String?
    
    private var showsPlaylist = false
    var liked = false {
        didSet {
            likeSongHandler()
        }
    }
    
    var trackLabelToThumbnailConstraint: NSLayoutConstraint!
    var trackLabelToViewConstraint: NSLayoutConstraint!
    var trackPlaceholderToThumbnailConstraint: NSLayoutConstraint!
    var trackPlaceholderToViewConstraint: NSLayoutConstraint!
    
    var trackLabelToThumbConstraint: NSLayoutConstraint!
    var trackLabelToPlaylistButton: NSLayoutConstraint!
    var likeDelegate: LikeDelegate!
    
    var trackRequestDelegate: TrackRequestDelegate!
    var id = 0
    
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
    
    let thumbButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        
        button.setImage(#imageLiteral(resourceName: "outline_thumb_up_black"), for: .normal)
        return button
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
    
    @objc func presentPlaylist() {
        let vc = AddToPlaylistTableViewController()
        let nc = UINavigationController(rootViewController: vc)
        let alert = UIAlertController(title: "Add to Playlist", message: "Choose which kind of playlist you want to add your song to", preferredStyle: .actionSheet)
        let eventAction = UIAlertAction(title: "Add to event playlist", style: .default) { (action) in
            vc.isRegularPlaylist = false
            self.toPlaylist(nc: nc, vc: vc)
        }
        let playlistAction = UIAlertAction(title: "Add to my playlist", style: .default) { (action) in
            vc.isEventPlaylist = false
            self.toPlaylist(nc: nc, vc: vc)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(eventAction)
        alert.addAction(playlistAction)
        delegateViewController?.present(alert, animated: true, completion: nil)
    }
    
    func toPlaylist(nc: UINavigationController, vc: AddToPlaylistTableViewController) {
        if currentTrack != nil {
            vc.track = currentTrack
            DispatchQueue.main.async {
                self.delegateViewController?.present(nc, animated: true, completion: nil)
            }
        }
        else {
            self.trackRequestDelegate.getTrack(id: self.id, completion: { (track, err) in
                if err != nil {
                    print(err)
                    return
                }
                vc.track = track
                DispatchQueue.main.async {
                    self.delegateViewController?.present(nc, animated: true, completion: nil)
                }
            })
        }
    }
    
    @objc private func toPlaylist(sender: UIButton) {
        let vc = AddToPlaylistTableViewController()
        let nc = UINavigationController(rootViewController: vc)
        if sender.currentTitle == "Events" {
            vc.isRegularPlaylist = false
        } else { vc.isEventPlaylist = false }
        vc.track = self.currentTrack
        self.delegateViewController?.present(nc, animated: true, completion: nil)
    }
    
    func setupLayout() {
        selectionStyle = .none
        addSubview(viewContainer)
        viewContainer.addSubview(addToPlaylistButton)
        viewContainer.addSubview(trackLabel)
        viewContainer.addSubview(trackPlaceholder)
        viewContainer.addSubview(thumbnail)
        viewContainer.addSubview(thumbButton)
        thumbButton.isHidden = true
        thumbButton.addTarget(self, action: #selector(thumbButtonAction), for: .touchDown)
        addToPlaylistButton.addTarget(self, action: #selector(presentPlaylist), for: .touchUpInside)
        
        trackLabelToThumbConstraint = trackLabel.trailingAnchor.constraint(equalTo: thumbButton.leadingAnchor, constant: -12)
        trackLabelToPlaylistButton = trackLabel.trailingAnchor.constraint(equalTo: addToPlaylistButton.leadingAnchor, constant: -12)
        trackLabelToThumbConstraint.priority = UILayoutPriority.defaultLow
        trackLabelToPlaylistButton.priority = UILayoutPriority.defaultHigh
        
        trackLabelToThumbnailConstraint = trackLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12)
        trackLabelToViewConstraint = trackLabel.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 12)
        trackLabelToThumbnailConstraint.priority = UILayoutPriority.defaultHigh
        trackLabelToViewConstraint.priority = UILayoutPriority.defaultLow
        
        trackPlaceholderToThumbnailConstraint = trackPlaceholder.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12)
        trackPlaceholderToViewConstraint = trackPlaceholder.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 12)
        trackPlaceholderToThumbnailConstraint.priority = UILayoutPriority.defaultHigh
        trackPlaceholderToViewConstraint.priority = UILayoutPriority.defaultLow
        
        let trackLabelWidth = trackLabel.widthAnchor.constraint(equalToConstant: 50)
        trackLabelWidth.priority = UILayoutPriority(rawValue: 251)

        NSLayoutConstraint.activate([
            viewContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            viewContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            viewContainer.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -24),
            viewContainer.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -20),
            thumbnail.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 12),
            thumbnail.heightAnchor.constraint(equalTo: viewContainer.heightAnchor, constant: -24),
            thumbnail.widthAnchor.constraint(equalTo: thumbnail.heightAnchor, multiplier: 1),
            addToPlaylistButton.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -12),
            addToPlaylistButton.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor, constant: 0),
            addToPlaylistButton.heightAnchor.constraint(equalToConstant: 25),
            addToPlaylistButton.widthAnchor.constraint(equalTo: addToPlaylistButton.heightAnchor),

            thumbButton.trailingAnchor.constraint(equalTo: addToPlaylistButton.leadingAnchor, constant: -12),
            thumbButton.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor, constant: 0),
            thumbButton.heightAnchor.constraint(equalToConstant: 25),
            thumbButton.widthAnchor.constraint(equalTo: thumbButton.heightAnchor),

            trackLabelToThumbnailConstraint,
            trackLabelToViewConstraint,
            trackLabelToPlaylistButton,
            trackLabelToThumbConstraint,
            trackLabelWidth,
            trackLabel.bottomAnchor.constraint(equalTo: thumbnail.centerYAnchor, constant: -5),
            trackPlaceholderToViewConstraint,
            trackPlaceholderToThumbnailConstraint,
            trackPlaceholder.widthAnchor.constraint(equalToConstant: 90),
            trackPlaceholder.topAnchor.constraint(equalTo: thumbnail.centerYAnchor, constant: 5),
            ])
    }
    
    func hideImageView(isHidden: Bool = false) {
        if (isHidden) {
            trackLabelToThumbnailConstraint.priority = UILayoutPriority.defaultLow
            trackLabelToViewConstraint.priority = UILayoutPriority.defaultHigh
            trackPlaceholderToThumbnailConstraint.priority = UILayoutPriority.defaultLow
            trackPlaceholderToViewConstraint.priority = UILayoutPriority.defaultHigh
            thumbnail.isHidden = true
        } else {
            trackPlaceholderToThumbnailConstraint.priority = UILayoutPriority.defaultHigh
            trackPlaceholderToViewConstraint.priority = UILayoutPriority.defaultLow
            trackLabelToThumbnailConstraint.priority = UILayoutPriority.defaultHigh
            trackLabelToViewConstraint.priority = UILayoutPriority.defaultLow
            thumbnail.isHidden = false
        }
    }
    
    func hideThumbButton(isHidden: Bool = false) {
        if (isHidden) {
            trackLabelToThumbConstraint.priority = UILayoutPriority.defaultLow
            trackLabelToPlaylistButton.priority = UILayoutPriority.defaultHigh
            thumbButton.isHidden = true
        } else {
            trackLabelToThumbConstraint.priority = UILayoutPriority.defaultHigh
            trackLabelToPlaylistButton.priority = UILayoutPriority.defaultLow
            thumbButton.isHidden = false
        }
    }
    
    @objc private func thumbButtonAction() {
        liked = !liked
        likeDelegate.updatelikes(track: currentTrack!, like: liked)
    }
    
    private func likeSongHandler() {
        if liked {
            thumbButton.setImage(#imageLiteral(resourceName: "baseline_thumb_up"), for: .normal)
        } else {
            thumbButton.setImage(#imageLiteral(resourceName: "outline_thumb_up_black"), for: .normal)
        }
    }
}
