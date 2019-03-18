//
//  AlbumTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/13/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Kingfisher
import JGProgressHUD


protocol AlbumLoadDelegate : class {
    func loadAlbum(songIndex: Int, cover: UIImage?, albumName: String?, songArray: [TrackCodable])
}

class AlbumDetailsTableViewController: UIViewController, TrackRequestDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var albumTracks: SearchRequest<TrackCodable>? {
        didSet {
            DispatchQueue.main.async {
                self.x.label.text = self.albumName
                Helpers.dismissHud(self.hud, text: "", detailText: "", delay: 0)
                self.tableView.reloadData()
            }
        }
    }
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.interactionType = .blockAllTouches
        hud.parallaxMode = .alwaysOff
        return hud
    }()
    
    var tableView: UITableView!
    var albumLoadDelegate: AlbumLoadDelegate!
    var artistName: String?
    var albumCoverURL: String?
    var albumName: String?
    var tracklist: String?
    let trackCellIdentifier = "trackCell"
    let imageView = UIImageView()
    var player: PlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Album"
   
        prepareTableView()
    }
    
    var x: ParallaxHeaderView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hud.show(in: view)
        downloadTracks()
        let parallaxViewFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width / 1.3)
        x = ParallaxHeaderView(frame: parallaxViewFrame)
        guard let picURL = albumCoverURL else { self.tableView.tableHeaderView  = x; return }
        let url = URL(string: picURL)
        x.imageView.kf.indicatorType = .activity
        x.imageView.kf.setImage(with: url)
        self.tableView.tableHeaderView  = x
    }
    
    func downloadTracks() {
        guard let x = tracklist else {  print("No url given"); return }
        let url = URL(string: x)
        guard let urlTask = url else { print("wrong url"); navigationController?.popViewController(animated: true); return }
        let task = URLSession.shared.dataTask(with: urlTask) { (data, url, err) in
            if err != nil {
                print(err!)
                return
            }
            guard let data = data else {  print("invalid data"); return }
            do {
                self.albumTracks = try JSONDecoder().decode(SearchRequest<TrackCodable>.self, from: data)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    fileprivate func prepareTableView() {
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: trackCellIdentifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.isUserInteractionEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keys.currentTrackViewHeight, right: 0)
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: trackCellIdentifier, for: indexPath) as! TrackTableViewCell
        cell.hideImageView(isHidden: true)
        cell.delegateViewController = self
        cell.trackRequestDelegate = self
        cell.id = albumTracks?.data[indexPath.row].id ?? 0
        cell.trackLabel.text = albumTracks?.data[indexPath.row].title
        cell.trackPlaceholder.text = artistName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tracks = albumTracks?.data else { return }
        player.loadAlbum(songIndex: indexPath.row, cover: albumCoverURL, albumName: albumName, songArray: tracks)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  albumTracks?.data.count ?? 0
    }
    
    func getTrack(id: Int, completion: @escaping ([String : Any]?, Error?) -> ()) {
        DeezerManager.search(id: "\(id)") { (track, err) in
            completion(track, err)
        }
    }
}

final class ParallaxHeaderView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(label)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -5),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            label.widthAnchor.constraint(equalTo: widthAnchor, constant: 24),
            ])
    }

}
