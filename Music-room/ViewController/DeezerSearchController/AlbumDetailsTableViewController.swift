//
//  AlbumTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/13/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Kingfisher


protocol AlbumLoadDelegate : class {
    func loadAlbum(songIndex: Int, cover: UIImage?, albumName: String?, songArray: [TrackCodable])
}

class AlbumDetailsTableViewController: UITableViewController, TrackRequestDelegate {

    var albumTracks: TrackArray? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    

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
        let parallaxViewFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width / 1.3)
        x = ParallaxHeaderView(frame: parallaxViewFrame)
        x.label.text = albumName
        let url = URL(string: albumCoverURL!)
        x.imageView.kf.setImage(with: url)
        self.tableView.tableHeaderView  = x
    }
    
    func downloadTracks() {
        guard let x = tracklist else {  print("No url given"); return }
        let url = URL(string: x)
        guard let urlTask = url else { print("wrong url"); return }
        let task = URLSession.shared.dataTask(with: urlTask) { (data, url, err) in
            if err != nil {
                print(err!)
                return
            }
            guard let data = data else {  print("invalid data"); return }
            do {
                self.albumTracks = try JSONDecoder().decode(TrackArray.self, from: data)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    fileprivate func prepareTableView() {
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: trackCellIdentifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.isUserInteractionEnabled = true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: trackCellIdentifier, for: indexPath) as! TrackTableViewCell
        cell.hideImageView(isHidden: true)
        cell.delegateViewController = self
        cell.trackRequestDelegate = self
        cell.id = (albumTracks?.data[indexPath.row].id)!
        cell.trackLabel.text = albumTracks?.data[indexPath.row].title
        cell.trackPlaceholder.text = artistName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        player.loadAlbum(songIndex: indexPath.row, cover: albumCoverURL, albumName: albumName, songArray: (albumTracks?.data)!)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  albumTracks?.data.count ?? 0
    }
    
    func getTrack(id: Int, completion: @escaping ([String : Any]?, Error?) -> ()) {
        DeezerManager1.search(id: "\(id)") { (track, err) in
            completion(track, err)
        }
    }
}

final class ParallaxHeaderView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    let imageView: UIImageView = {
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
