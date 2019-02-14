//
//  TabBarController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/6/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit


protocol SearchDelegate: class {
    func hideNavBar()
}

class TabBarController: UITabBarController, AlbumLoadDelegate, TrackDelegate, PlayerTabBarDelegate {
    var currentTrackHeightConstraint: NSLayoutConstraint!
    func loadTrack(songIndex: Int, cover: UIImage?, songArray: [TrackCodable]) {
        vc.songIndex = 0
        vc.songArray = songArray
        vc.coverImage = cover
        vc.setCollectionPosition()
        vc.collectionView.reloadData()
        displayCurrentTrackView()

    }

    func loadAlbum(songIndex: Int, cover: UIImage?, albumName: String?, songArray: [TrackCodable]) {
        vc.songIndex = songIndex
        vc.coverImage = cover
        vc.albumName = albumName
        vc.songArray = songArray
        vc.setCollectionPosition()
        vc.collectionView.reloadData()
        displayCurrentTrackView()
    }
    
    var currentTrackIsHidden = true
    let currentTrackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    let currentTrackButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "outline_pause"), for: .normal)
        return button
    }()
    
    let currentTrackLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "erfgerferferbferhfvehrfvhrvfekfvrferfe"
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    
    @objc func displayPlayer() {
        vc.showView()
        hideTabBar()
    }

    let vc = PlayerViewController()
    var tabBarY: CGFloat!
    override func viewDidLoad() {
        super.viewDidLoad()
        vc.tabBarDelegate = self
        let searchViewController = SearchTableViewController()
        let tap = UITapGestureRecognizer(target: self, action: #selector(displayPlayer))
        tap.numberOfTapsRequired = 1
        currentTrackView.addGestureRecognizer(tap)
        searchViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        let tabBarList = [ searchViewController ]
        viewControllers = tabBarList.map { UINavigationController(rootViewController: $0) }
        setupCurrentTrackView()
        vc.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        view.addSubview(vc.view)
        NotificationCenter.default.addObserver(self, selector: #selector(toPauseButton), name: .songPlay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toPlayButton), name: .songPause, object: nil)
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarY = tabBar.frame.minY
    }
  
    @objc func toPlayButton() {
        print("should display play")
         changeCurrentTrackViewDisplay()
        currentTrackButton.setImage(UIImage(named:"outline_play"), for: .normal)
    }
    @objc func toPauseButton() {
        print("should display pause")
         changeCurrentTrackViewDisplay()
        currentTrackButton.setImage(UIImage(named:"outline_pause"), for: .normal)
    }
    
    func setupCurrentTrackView() {
        currentTrackHeightConstraint = currentTrackView.heightAnchor.constraint(equalToConstant: 0)
        currentTrackButton.addTarget(self, action: #selector(pauseSong), for: .touchUpInside)
        currentTrackButton.isHidden = true
        currentTrackLabel.isHidden = true
        currentTrackView.addSubview(currentTrackButton)
        currentTrackView.addSubview(currentTrackLabel)
        view.addSubview(currentTrackView)
        NSLayoutConstraint.activate([
            currentTrackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            currentTrackView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            currentTrackHeightConstraint,
            currentTrackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        
            currentTrackButton.trailingAnchor.constraint(equalTo: currentTrackView.trailingAnchor, constant: -12),
            currentTrackButton.centerYAnchor.constraint(equalTo: currentTrackView.centerYAnchor),
            currentTrackButton.heightAnchor.constraint(equalToConstant: 40),
            currentTrackButton.widthAnchor.constraint(equalToConstant: 40),
            
            currentTrackLabel.trailingAnchor.constraint(equalTo: currentTrackButton.leadingAnchor, constant: -12),
            currentTrackLabel.heightAnchor.constraint(equalToConstant: 20),
            currentTrackLabel.centerYAnchor.constraint(equalTo: currentTrackView.centerYAnchor),
            currentTrackLabel.leadingAnchor.constraint(equalTo: currentTrackView.leadingAnchor, constant: 64),
            ])
    }
    
    @objc func pauseSong() {
        vc.playPauseAction()
    }
    
    func displayCurrentTrackView() {
        if currentTrackIsHidden {
            currentTrackButton.isHidden = false
            currentTrackLabel.isHidden = false
            changeCurrentTrackViewDisplay()
            UIView.animate(withDuration: 2) {
                self.currentTrackHeightConstraint.constant = keys.currentTrackViewHeight
            }
            currentTrackIsHidden = false
        }
    }
    
    func changeCurrentTrackViewDisplay() {
        let track = vc.songArray[vc.songIndex]
        let attributedText = NSMutableAttributedString(string: "\(track.title) • ", attributes: [.font: UIFont.boldSystemFont(ofSize: 12), .foregroundColor: UIColor.white])
        attributedText.append(NSAttributedString(string: "\(track.artist.name)", attributes: [.font: UIFont.boldSystemFont(ofSize: 12),.foregroundColor: UIColor.gray]))
        currentTrackLabel.attributedText = attributedText
    }
    
    func updateTabBarRatio(ratio: CGFloat) {
        if ratio == 0.0 {
            UIView.animate(withDuration: 0.2) {
                self.tabBar.frame = CGRect(x: self.tabBar.frame.minX, y: UIScreen.main.bounds.height, width: self.tabBar.frame.width, height: self.tabBar.frame.height)
            }
        }
        let x = UIScreen.main.bounds.height - tabBarY
        tabBar.frame = CGRect(x: tabBar.frame.minX, y: UIScreen.main.bounds.height - (x * ratio), width: tabBar.frame.width, height: tabBar.frame.height)
//        currentTrackHeightConstraint.constant = keys.currentTrackViewHeight * ratio
    }

    func displayTabBar() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
            self.tabBar.frame = CGRect(x: self.tabBar.frame.minX, y: self.tabBarY, width: self.tabBar.frame.width, height: (self.tabBar.frame.height))
        }) {
            (bo) in
            UIView.animate(withDuration: 0.2, animations: {
                self.currentTrackHeightConstraint.constant = keys.currentTrackViewHeight
            })
        }
    }
    
    func hideTabBar() {
        UIView.animate(withDuration: 0.2) {
            self.tabBar.frame = CGRect(x: self.tabBar.frame.minX, y: UIScreen.main.bounds.height, width: self.tabBar.frame.width, height: self.tabBar.frame.height)
            self.currentTrackHeightConstraint.constant = 0
        }
    }

}
