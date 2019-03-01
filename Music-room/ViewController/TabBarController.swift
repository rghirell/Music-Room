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

class TabBarController: UITabBarController, PlayerTabBarDelegate {
    
    //MARK: -
    //MARK: View Components
    let vc = PlayerViewController()
    var currentTrackHeightConstraint: NSLayoutConstraint!
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
//        label.text = "erfgerferferbferhfvehrfvhrvfekfvrferfe"
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let currentTrackIV: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = iv.frame.height / 2
        return iv
    }()

    
    //MARK: -
    //MARK: View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBars()
        setupCurrentTrackView()
        vc.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        vc.tabBarDelegate = self
        view.addSubview(vc.view)
        NotificationCenter.default.addObserver(self, selector: #selector(toPauseButton), name: .songPlay, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toPlayButton), name: .songPause, object: nil)
    }
    
    var tabBarY: CGFloat!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarY = tabBar.frame.minY
    }
  
    func setupTabBars() {
        let searchViewController = SearchTableViewController()
        let playlistTableViewVC = PlaylistTableViewController()
        searchViewController.player = vc
        playlistTableViewVC.player = vc
        playlistTableViewVC.tabBarItem =  UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
        searchViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        let tabBarList = [ playlistTableViewVC, searchViewController ]
        viewControllers = tabBarList.map { UINavigationController(rootViewController: $0) }
    }
    
    func setupCurrentTrackView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(displayPlayer))
        tap.numberOfTapsRequired = 1
        currentTrackView.alpha = 0.93
        currentTrackView.addGestureRecognizer(tap)
        currentTrackHeightConstraint = currentTrackView.heightAnchor.constraint(equalToConstant: 0)
        currentTrackButton.addTarget(self, action: #selector(pauseSong), for: .touchUpInside)
        currentTrackView.isHidden = true
        currentTrackView.addSubview(currentTrackButton)
        currentTrackView.addSubview(currentTrackLabel)
        currentTrackView.addSubview(currentTrackIV)
        
        view.addSubview(currentTrackView)
        NSLayoutConstraint.activate([
            currentTrackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            currentTrackView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            currentTrackHeightConstraint,
            currentTrackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            currentTrackIV.centerYAnchor.constraint(equalTo: currentTrackView.centerYAnchor),
            currentTrackIV.leadingAnchor.constraint(equalTo: currentTrackView.leadingAnchor, constant: 12),
            currentTrackIV.heightAnchor.constraint(equalToConstant: 40),
            currentTrackIV.widthAnchor.constraint(equalTo: currentTrackIV.heightAnchor, multiplier: 1),
        
            currentTrackButton.trailingAnchor.constraint(equalTo: currentTrackView.trailingAnchor, constant: -12),
            currentTrackButton.centerYAnchor.constraint(equalTo: currentTrackView.centerYAnchor),
            currentTrackButton.heightAnchor.constraint(equalToConstant: 40),
            currentTrackButton.widthAnchor.constraint(equalToConstant: 40),
            
            currentTrackLabel.trailingAnchor.constraint(equalTo: currentTrackButton.leadingAnchor, constant: -12),
            currentTrackLabel.heightAnchor.constraint(equalToConstant: 20),
            currentTrackLabel.centerYAnchor.constraint(equalTo: currentTrackView.centerYAnchor),
            currentTrackLabel.leadingAnchor.constraint(equalTo: currentTrackIV.trailingAnchor, constant: 12),
            ])
    }
    
    //MARK: -
    //MARK: View Animations
    func updateTabBarRatio(ratio: CGFloat) {
        tabBar.layer.zPosition = 1000
        print("update")
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
    
    func displayCurrentTrackView() {
        if currentTrackIsHidden {
           currentTrackView.isHidden = false
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
        let url = URL(string: vc.coverImage!)
        currentTrackIV.kf.setImage(with: url)
        currentTrackIV.layer.masksToBounds = true
        currentTrackIV.layer.cornerRadius = CGFloat(roundf(Float(currentTrackIV.frame.size.width/2.0)))
        currentTrackLabel.attributedText = attributedText
    }

    //MARK: -
    //MARK: Player controls
    @objc func pauseSong() {
        vc.playPauseAction()
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
    
    @objc func displayPlayer() {
        vc.showView()
        hideTabBar()
    }
}
