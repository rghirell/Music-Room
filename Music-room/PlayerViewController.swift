//
//  PlayerViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/9/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    var songPlayer = AVAudioPlayer()
    var isPlaying = false
    let playImage = UIImage(named: "play")
    let pauseImage = UIImage(named: "pause")
    
    var songURL: String? {
        didSet {
            downloadSong()
        }
    }
    
    let coverView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .red
        return imageView
    }()
    
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
//        button.addTarget(self, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    let playPauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(playPauseAction), for: .touchUpInside)
        let image = UIImage(named: "pause")
        button.setImage(image, for: .normal)
        return button
    }()
    
    let placeHolder: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "placeholder"
        return label
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupLayout()
    }
    
    fileprivate func downloadSong() {
        let url = URL(string: songURL!)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, err) in
            if err != nil {
                print(err)
                return
            }
            DispatchQueue.main.async {
                self.playSong(data: data!)
            }
        }.resume()
    }
    
    @objc func playPauseAction() {
        if isPlaying {
            playPauseButton.setImage(playImage, for: .normal)
            songPlayer.pause()
            isPlaying = false
        } else {
            playPauseButton.setImage(pauseImage, for: .normal)
            songPlayer.play()
             isPlaying = true
        }
        
    }
    
    fileprivate func playSong(data: Data) {
        do {
            songPlayer = try AVAudioPlayer(data: data)
            //8 - Prepare the song to be played
            songPlayer.prepareToPlay()
            
            //9 - Create an audio session
            let audioSession = AVAudioSession.sharedInstance()
            do {
                //10 - Set our session category to playback music
                try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
                songPlayer.play()
                isPlaying = true
                //11 -
            } catch let sessionError {
                print(sessionError)
            }
            //12 -
        } catch let songPlayerError {
            print(songPlayerError)
        }
    }
    
    
    fileprivate func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [prevButton, playPauseButton, nextButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let screenSize = UIScreen.main.bounds
        let buttonSize = 50.0 as CGFloat
        let prevNextSize = 30.0 as CGFloat
        var minimumSpaceConstant = screenSize.height * 0.065
        var imageConstraintMultiplier = CGFloat(0.84)
        print(screenSize)
   
        view.addSubview(playPauseButton)
        view.addSubview(prevButton)
        view.addSubview(nextButton)
        view.addSubview(placeHolder)
        view.addSubview(trackLabel)
        view.addSubview(artistLabel)
        view.addSubview(coverView)
        view.addSubview(albumLabel)

        if screenSize.height <= 700 {
            print("hello")
            minimumSpaceConstant = screenSize.height * 0.04
            imageConstraintMultiplier = CGFloat(0.7)
        }
        
        
        prevButton.imageEdgeInsets = UIEdgeInsets(top: prevNextSize, left: prevNextSize, bottom: prevNextSize, right: prevNextSize)
        nextButton.imageEdgeInsets = UIEdgeInsets(top: prevNextSize, left: prevNextSize, bottom: prevNextSize, right: prevNextSize)
        playPauseButton.imageEdgeInsets = UIEdgeInsets(top: buttonSize, left:buttonSize, bottom: buttonSize, right: buttonSize)
    

        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            prevButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -40),
            prevButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 40),
            placeHolder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeHolder.bottomAnchor.constraint(equalTo: playPauseButton.topAnchor, constant: -40),
            artistLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artistLabel.bottomAnchor.constraint(equalTo: placeHolder.topAnchor, constant: -5),
            trackLabel.bottomAnchor.constraint(equalTo: artistLabel.topAnchor, constant: -5),
            trackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coverView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            coverView.bottomAnchor.constraint(equalTo: trackLabel.topAnchor, constant: -30),
            coverView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: imageConstraintMultiplier),
            coverView.heightAnchor.constraint(equalTo: coverView.widthAnchor),
            coverView.bottomAnchor.constraint(greaterThanOrEqualTo: trackLabel.topAnchor, constant: -minimumSpaceConstant),
            albumLabel.bottomAnchor.constraint(greaterThanOrEqualTo: coverView.topAnchor, constant: -(minimumSpaceConstant + 5)),
            albumLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
    }
    


}
