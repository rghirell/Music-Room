//
//  PlayerView.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/11/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

class PlayerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
//    var songPlayer = AVAudioPlayer()
    var isPlaying = false
    let playImage = UIImage(named: "play")
    let pauseImage = UIImage(named: "pause")
    private var timer: Timer?
    private let reuseIdentifier = "DateCell"
    var songArray: [MixedModel] = [] {
        didSet {
//            displayInfo()
//            downloadSong()
        }
    }
    
    var songIndex: Int = 2
    
    let nextButton : UIButton = {
        let button = UIButton()
        let image = UIImage(named: "next")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let prevButton : UIButton = {
        let button = UIButton()
        let image = UIImage(named: "previous")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let playPauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
//        button.addTarget(self, action: #selector(playPauseAction), for: .touchUpInside)
        let image = UIImage(named: "pause")
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
        label.text = "track"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let albumLabel: UILabel = {
        let label = UILabel()
        label.text = "album"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        //        songPlayer.delegate = self
//        view.backgroundColor = .red
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        previousPage = songIndex
//        collectionView.register(CoverCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
//        view.addGestureRecognizer(swipeGesture)
//        swipeGesture.direction = .down
//        setupLayout()
//    }
    
//    @objc func swipeDown() {
//        print("swiped down")
//        UIView.animate(withDuration: 1) {
//            self.view.alpha = 0
//        }
//    }
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        setCollectionPosition()
//    }
    
//    fileprivate func downloadSong() {
//        let url = URL(string: songArray[songIndex].preview!)
//        URLSession.shared.dataTask(with: url!) { (data, response, err) in
//            if err != nil {
//                print(err)
//                return
//            }
//            DispatchQueue.main.async {
//                self.playSong(data: data!)
//            }
//            }.resume()
//    }
    
//    @objc func playPauseAction() {
//        print("playpause")
//        if isPlaying {
//            playPauseButton.setImage(playImage, for: .normal)
//            songPlayer.pause()
//            timer?.invalidate()
//            isPlaying = false
//        } else {
//            playPauseButton.setImage(pauseImage, for: .normal)
//            songPlayer.play()
//            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshStatusBar), userInfo: nil, repeats: true)
//            isPlaying = true
//        }
//    }
    
//    fileprivate func playSong(data: Data) {
//        do {
//            songPlayer = try AVAudioPlayer(data: data)
//            songPlayer.delegate = self
//            //8 - Prepare the song to be played
//            songPlayer.prepareToPlay()
//
//            //9 - Create an audio session
//            let audioSession = AVAudioSession.sharedInstance()
//            do {
//                //10 - Set our session category to playback music
//                try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
//                try AVAudioSession.sharedInstance().setActive(true)
//                songPlayer.play()
//                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshStatusBar), userInfo: nil, repeats: true)
//                isPlaying = true
//                playPauseButton.setImage(pauseImage, for: .normal)
//                //11 -
//            } catch let sessionError {
//                print(sessionError)
//            }
//            //12 -
//        } catch let songPlayerError {
//            print(songPlayerError)
//        }
//    }
    
//    fileprivate func displayInfo() {
//        albumLabel.text = songArray[songIndex].album?.title
//        artistLabel.text = songArray[songIndex].artist?.name
//        trackLabel.text = songArray[songIndex].name
//    }
//
//    @objc func refreshStatusBar() {
//        //        print(songPlayer.currentTime)
//        self.timeSlider.value = Float(self.songPlayer.currentTime)
//    }
    
//    @objc func changedTimer() {
//        timer?.invalidate()
//    }
    
//    @objc func updateTimer() {
//        songPlayer.currentTime = Double(timeSlider.value)
//        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshStatusBar), userInfo: nil, repeats: true)
//    }
//
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        print("hello there")
//        playPauseButton.setImage(playImage, for: .normal)
//        timeSlider.value = 0
//        isPlaying = false
//        timeSlider.cancelTracking(with: nil)
//        timer?.invalidate()
//    }
    
//
//    fileprivate func setupLayout() {
//        let stackView = UIStackView(arrangedSubviews: [prevButton, playPauseButton, nextButton])
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        let screenSize = UIScreen.main.bounds
//        let buttonSize = 50.0 as CGFloat
//        let prevNextSize = 30.0 as CGFloat
//        var minimumSpaceConstant = screenSize.height * 0.065
//        var imageConstraintMultiplier = CGFloat(0.84)
//        timeSlider.minimumTrackTintColor = .white
//        timeSlider.setThumbImage(UIImage(named: "icon"), for: .normal)
//        addSubview(playPauseButton)
//        addSubview(prevButton)
//        addSubview(nextButton)
//        addSubview(timeSlider)
//        addSubview(trackLabel)
//        addSubview(artistLabel)
//        addSubview(albumLabel)
//        addSubview(collectionView)
//
//        if screenSize.height <= 700 {
//            print("hello")
//            minimumSpaceConstant = screenSize.height * 0.04
//            imageConstraintMultiplier = CGFloat(0.7)
//        }
//
//
//        prevButton.imageEdgeInsets = UIEdgeInsets(top: prevNextSize, left: prevNextSize, bottom: prevNextSize, right: prevNextSize)
//        nextButton.imageEdgeInsets = UIEdgeInsets(top: prevNextSize, left: prevNextSize, bottom: prevNextSize, right: prevNextSize)
//        playPauseButton.imageEdgeInsets = UIEdgeInsets(top: buttonSize, left:buttonSize, bottom: buttonSize, right: buttonSize)
//        timeSlider.maximumValue = 30
//        timeSlider.addTarget(self, action: #selector(changedTimer), for: .touchDown)
//        timeSlider.addTarget(self, action: #selector(updateTimer), for: .touchUpInside)
//        timeSlider.addTarget(self, action: #selector(updateTimer), for: .touchUpOutside)
//
//        NSLayoutConstraint.activate([
//            playPauseButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
//            playPauseButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -100),
//            prevButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -40),
//            prevButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
//            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
//            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 40),
//            timeSlider.centerXAnchor.constraint(equalTo: centerXAnchor),
//            timeSlider.bottomAnchor.constraint(equalTo: playPauseButton.topAnchor, constant: -40),
//            timeSlider.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, constant: -24),
//            artistLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            artistLabel.bottomAnchor.constraint(equalTo: timeSlider.topAnchor, constant: -5),
//            trackLabel.bottomAnchor.constraint(equalTo: artistLabel.topAnchor, constant: -5),
//            trackLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            albumLabel.bottomAnchor.constraint(greaterThanOrEqualTo: collectionView.topAnchor, constant: -(minimumSpaceConstant + 5)),
//            albumLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: 24),
//            albumLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            collectionView.centerXAnchor.constraint(equalTo: centerXAnchor),
//            collectionView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 1),
//            collectionView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: imageConstraintMultiplier),
//            collectionView.bottomAnchor.constraint(greaterThanOrEqualTo: trackLabel.topAnchor, constant: -minimumSpaceConstant),
//            ])
//    }
//
//    //MARK: -
//    //MARK: CollectionView
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return songArray.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CoverCollectionViewCell
//        //        cell.backgroundColor = .blue
//        cell.coverCollectionView.image = songArray[indexPath.row].picture
//        return cell
//    }
//
//    let collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
//        cv.backgroundColor = .none
//        cv.showsHorizontalScrollIndicator = false
//        cv.isPagingEnabled = true
//        cv.translatesAutoresizingMaskIntoConstraints = false
//        return cv
//    }()
    
//    var safeAreaLayoutGuide: UILayoutGuide {
//        return UILayoutGuide()
//    }
    
    
    
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: view.frame.width, height: collectionView.frame.height)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//
    
//    var previousPage: Int?
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let x = Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
//        if previousPage != x {
//            print(x)
//            songPlayer.pause()
//            timer?.invalidate()
//            songIndex = x
//            timeSlider.value = 0
//            displayInfo()
//            downloadSong()
//            previousPage = x
//        }
//    }
    
//    func setCollectionPosition() {
//        let contentOffset = CGFloat(floor(0 + UIScreen.main.bounds.width)) * CGFloat(songIndex)
//        collectionView.contentOffset = CGPoint(x: contentOffset, y: 0)
//        print(contentOffset)
//    }

}
