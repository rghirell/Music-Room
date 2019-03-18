//
//  PlayerViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/9/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

protocol PlayerTabBarDelegate: class {
    func updateTabBarRatio(ratio: CGFloat)
    func displayTabBar()
    func displayCurrentTrackView()
}

class PlayerViewController: UIViewController , AVAudioPlayerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var imageView : UIImageView!
    var songPlayer = AVAudioPlayer()
    var isPanActivated = false
    private var state = State.pause {
        didSet {
            stateChanged()
        }
    }
    let playImage = UIImage(named: "white_play_circle")
    let pauseImage = UIImage(named: "white_pause_circle")
    var albumName: String?
    weak var tabBarDelegate: PlayerTabBarDelegate!
    private var timer: Timer?
    private let reuseIdentifier = "DateCell"
    var coverImage: String?
    var songArray: [TrackCodable] = [] {
        didSet {
            displayInfo()
            downloadSong()
        }
    }
    
    var songIndex: Int = 0
    private let notificationCenter: NotificationCenter = .default
    
    // MARK: -
    // MARK: - View Element
    let nextButton : UIButton = {
        let button = UIButton()
        button.tag = 10
        let image = UIImage(named: "skip_next_white")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(prevNextAction), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    let blurryLayer: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let hideViewButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "downArrow"), for: .normal)
        button.addTarget(self, action: #selector(swipeDown), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let prevButton : UIButton = {
        let button = UIButton()
        button.tag = 11
        button.addTarget(self, action: #selector(prevNextAction), for: .touchUpInside)
        let image = UIImage(named: "skip_previous_white")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let playPauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(playPauseAction), for: .touchUpInside)
        let image = UIImage(named: "white_pause_circle")
        button.setImage(image, for: .normal)
        return button
    }()
    
    let timeSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    let artistLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(16)
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Artist"
        return label
    }()
    
    let trackLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.text = "track"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let albumLabel: UILabel = {
        let label = UILabel()
        label.text = "album"
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "-:--"
        label.font = label.font.withSize(12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let currentDurationLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(12)
        label.text = "-:--"
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var panGesture = UIPanGestureRecognizer()
    var viewY: CGFloat = 0
    
    var allViews: [UIView]?
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupGesture()
        setupCollectionView()
        setupLayout()
        previousPage = songIndex
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action:#selector(playPauseAction))
        commandCenter.playCommand.addTarget(self, action:#selector(playPauseAction))
    }
    
    fileprivate func stateChanged() {
        switch state {
        case .play:
            notificationCenter.post(name: .songPlay, object: true)
        case .pause:
            notificationCenter.post(name: .songPause, object: false)
        }
    }
    
    fileprivate func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView))
        view.addGestureRecognizer(panGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    fileprivate func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CoverCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc func willEnterBackground() {
        if isPanActivated {
            isPanActivated = false
            swipeDown()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("SongPlayer Disappear")
        setCollectionPosition()
    }
 
    
    @objc func draggedView(sender:UIPanGestureRecognizer) {
        isPanActivated = true
        let translation = sender.translation(in: self.view)
        let velocity = sender.velocity(in: self.view)
        if (translation.y < 0) {
            self.view.frame = CGRect(x: self.view.frame.minX, y: self.viewY, width: self.view.frame.width, height: self.view.frame.height)
            isPanActivated = false
            return
        }
        if (sender.state == .ended && velocity.y >= 1200.0) {
            swipeDown()
            isPanActivated = false
            return
        }
        else if (sender.state == .ended) {
            UIView.animate(withDuration: 0.3) {
            self.view.frame = CGRect(x: self.view.frame.minX, y: self.viewY, width: self.view.frame.width, height: self.view.frame.height)
            }
            tabBarDelegate.updateTabBarRatio(ratio: 0.0)
            isPanActivated = false
            return
        }
        self.view.frame = CGRect(x: view.frame.minX, y: viewY + translation.y, width: view.frame.width, height: view.frame.height)
        let ratio = translation.y / UIScreen.main.bounds.height
        tabBarDelegate.updateTabBarRatio(ratio: ratio)
    }
    
    @objc func swipeDown() {
        tabBarDelegate.displayTabBar()
        UIView.animate(withDuration: 0.3) {
            self.view.frame = CGRect(x: self.view.frame.minX, y: UIScreen.main.bounds.height, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
    
    
    
    fileprivate func downloadSong() {
        playPauseButton.isEnabled = false
        let url = URL(string: songArray[songIndex].preview)
        URLSession.shared.dataTask(with: url!) { (data, response, err) in
            if err != nil {
                print(err!)
                return
            }
            DispatchQueue.main.async {
                self.playPauseButton.isEnabled = true
                self.playSong(data: data!)
                self.updateDuration()
            }
        }.resume()
    }
    
    func showView() {
        UIView.animate(withDuration: 0.3) {
            self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
    }
    
    @objc func playPauseAction() {
        print("playpause", state)
        switch state {
        case .play:
            playPauseButton.setImage(playImage, for: .normal)
            songPlayer.pause()
            timer?.invalidate()
            state = .pause
        case .pause:
            playPauseButton.setImage(pauseImage, for: .normal)
            songPlayer.play()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshStatusBar), userInfo: nil, repeats: true)
            state = .play
        }
    }
    
    @objc func prevNextAction(_ sender: UIButton) {
        var index = songIndex
        if sender.tag == 10 {
            index = songIndex + 1
        } else { index = songIndex - 1 }
        if index < 0 {
            index = 0
        }
        if index >= songArray.count {
            return
        }
        loadAlbum(songIndex: index, cover: coverImage, albumName: albumName, songArray: songArray
        )
    }
    
    fileprivate func playSong(data: Data) {
        do {
            songPlayer = try AVAudioPlayer(data: data)
            songPlayer.delegate = self
            //8 - Prepare the song to be played
            songPlayer.prepareToPlay()
            //9 - Create an audio session
            let audioSession = AVAudioSession.sharedInstance()
            do {
                //10 - Set our session category to playback music
                try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
                songPlayer.play()
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshStatusBar), userInfo: nil, repeats: true)
              
                state = .play
                playPauseButton.setImage(pauseImage, for: .normal)
                //11 -
            } catch let sessionError {
                print(sessionError)
            }
            //12 -
        } catch let songPlayerError {
            print(songPlayerError)
        }
    }
    
    fileprivate func displayInfo() {
        albumLabel.text = songArray[songIndex].album?.title ?? albumName
        artistLabel.text = songArray[songIndex].artist!.name
        trackLabel.text = songArray[songIndex].title
    }
    
    @objc func refreshStatusBar() {
        updateCurrentDuration()
        self.timeSlider.value = Float(self.songPlayer.currentTime)
        
    }
    
    @objc func changedTimer() {
        timer?.invalidate()
    }
    
    @objc func updateTimer() {
        songPlayer.currentTime = Double(timeSlider.value)
        updateCurrentDuration()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshStatusBar), userInfo: nil, repeats: true)
    }
   
    func updateCurrentDuration() {
        var secStr = ""
        let min = songPlayer.currentTime / 60
        let sec = Int(round(songPlayer.currentTime.truncatingRemainder(dividingBy: 60)))
        
        if sec < 10 {
            secStr = "0\(Int(sec))"
        } else { secStr = "\(sec)" }
        currentDurationLabel.text = "\(Int(min)):\(secStr)"
    }
    
    func updateDuration() {
        let duration = songArray[songIndex].duration
        if duration > 30 {
            durationLabel.text = "0:30"
            timeSlider.maximumValue = 30.0
            return
        }
        var secStr = ""
        let sec = songArray[songIndex].duration % 60
        if sec < 10 {
            secStr = "0\(Int(sec))"
        } else { secStr = "\(sec)" }
        durationLabel.text = "0:\(secStr)"
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playPauseButton.setImage(playImage, for: .normal)
        currentDurationLabel.text = "0:00"
        timeSlider.value = 0
        state = .pause
        timeSlider.cancelTracking(with: nil)
        timer?.invalidate()
        if songIndex < songArray.count - 1 {
            loadAlbum(songIndex: songIndex + 1, cover: coverImage, albumName: albumName, songArray: songArray)
        }
    }
    
    func loadTrack(songIndex: Int, cover: String?, songArray: [TrackCodable]) {
        self.songIndex = 0
        self.songArray = songArray
        coverImage = cover
        setCollectionPosition()
        collectionView.reloadData()
        tabBarDelegate.displayCurrentTrackView()
    }
    
    func loadAlbum(songIndex: Int, cover: String?, albumName: String?, songArray: [TrackCodable]) {
        self.songIndex = songIndex
        self.coverImage = cover
        self.albumName = albumName
        self.songArray = songArray
        self.setCollectionPosition()
        self.collectionView.reloadData()
        tabBarDelegate.displayCurrentTrackView()
    }

    fileprivate func setupLayout() {
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        viewY = view.frame.minY
        assignBackground()
        let screenSize = UIScreen.main.bounds
        let buttonSize = 64.0 as CGFloat
        var minimumSpaceConstant = screenSize.height * 0.065
        var imageConstraintMultiplier = CGFloat(0.84)
        
        blurryLayer.frame = view.bounds
        blurryLayer.alpha = 0.75
      
        timeSlider.minimumTrackTintColor = .white
        timeSlider.setThumbImage(UIImage(named: "icon"), for: .normal)
    
        allViews = [blurryLayer,currentDurationLabel, durationLabel, albumLabel, trackLabel, artistLabel, timeSlider, playPauseButton, prevButton, nextButton, collectionView, hideViewButton]
        
        for x in allViews! {
            self.view.addSubview(x)
        }
        
        if screenSize.height <= 700 {
            minimumSpaceConstant = screenSize.height * 0.04
            imageConstraintMultiplier = CGFloat(0.7)
        }
        
        playPauseButton.imageEdgeInsets = UIEdgeInsets(top: buttonSize, left:buttonSize, bottom: buttonSize, right: buttonSize)
        timeSlider.maximumValue = 30
        timeSlider.addTarget(self, action: #selector(changedTimer), for: .touchDown)
        timeSlider.addTarget(self, action: #selector(updateTimer), for: .touchUpInside)
        timeSlider.addTarget(self, action: #selector(updateTimer), for: .touchUpOutside)

        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            
            prevButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -40),
            prevButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 40),
            timeSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeSlider.bottomAnchor.constraint(equalTo: playPauseButton.topAnchor, constant: -40),
            timeSlider.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -24),
            artistLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artistLabel.bottomAnchor.constraint(equalTo: timeSlider.topAnchor, constant: -5),
            artistLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24),
            trackLabel.bottomAnchor.constraint(equalTo: artistLabel.topAnchor, constant: -5),
            trackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24),
            albumLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            albumLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -60),
            albumLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hideViewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            hideViewButton.topAnchor.constraint(equalTo: albumLabel.topAnchor),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1),
            collectionView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: imageConstraintMultiplier),
            collectionView.bottomAnchor.constraint(equalTo: trackLabel.topAnchor, constant: -minimumSpaceConstant),
            currentDurationLabel.topAnchor.constraint(equalTo: timeSlider.bottomAnchor, constant: 4),
            currentDurationLabel.leadingAnchor.constraint(equalTo: timeSlider.leadingAnchor, constant: 0),
            durationLabel.topAnchor.constraint(equalTo: timeSlider.bottomAnchor, constant: 4),
            durationLabel.trailingAnchor.constraint(equalTo: timeSlider.trailingAnchor, constant: 0)
            ])
    }
    
    //MARK: -
    //MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CoverCollectionViewCell
        let url = URL(string: coverImage!)
        cell.coverCollectionView.kf.setImage(with: url)
        return cell
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .none
        cv.showsHorizontalScrollIndicator = false
        cv.isPagingEnabled = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    var safeAreaLayoutGuide: UILayoutGuide {
        return UILayoutGuide()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    var previousPage: Int?
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
        if previousPage != x {
            print(x)
            songPlayer.pause()
            state = .pause
            timer?.invalidate()
            songIndex = x
            timeSlider.value = 0
            displayInfo()
            downloadSong()
            previousPage = x
        }
    }

    func setCollectionPosition() {
        let contentOffset = CGFloat(floor(0 + UIScreen.main.bounds.width)) * CGFloat(songIndex)
        collectionView.contentOffset = CGPoint(x: contentOffset, y: 0)
    }
}

private extension PlayerViewController {
    enum State {
        case play
        case pause
    }
}

extension Notification.Name {
    static var songPlay: Notification.Name {
        return .init(rawValue: "Player.plays")
    }
    static var songPause: Notification.Name {
        return .init(rawValue: "Player.pauses")
    }

}
