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
        vc.setCollectionPosition()
        vc.coverImage = cover
        vc.collectionView.reloadData()
        displayCurrentTrackView()
        vc.albumName = albumName
        vc.songArray = songArray
    }
    
    var currentTrackIsHidden = true
    let currentTrackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        return view
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
        
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       tabBarY = tabBar.frame.minY
    }
    
    func setupCurrentTrackView() {
        currentTrackHeightConstraint = currentTrackView.heightAnchor.constraint(equalToConstant: 800)
        view.addSubview(currentTrackView)
        NSLayoutConstraint.activate([
            currentTrackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            currentTrackView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            currentTrackHeightConstraint,
            currentTrackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
    }
    
    func displayCurrentTrackView() {
        if currentTrackIsHidden {
            UIView.animate(withDuration: 2) {
                self.currentTrackHeightConstraint.constant = keys.currentTrackViewHeight
            }
            currentTrackIsHidden = false
        }
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
