//
//  TrackTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/22/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

protocol TrackDelegate: class {
    func loadTrack(songIndex: Int, cover: UIImage?, songArray: [TrackCodable])
}

class PlaylistTrackTableViewController: UITableViewController {
    
    var trackArray: [[String: Any]]? {
        didSet {
            tableView.reloadData()
        }
    }
    fileprivate let imageCache = NSCache<AnyObject, AnyObject>()
    var player: PlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    fileprivate func setupTableView() {
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keys.currentTrackViewHeight, right: 0)
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: CellIdentifier.trackCell)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackArray?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.trackCell, for: indexPath) as! TrackTableViewCell
        guard let trackArray = self.trackArray else { return UITableViewCell() }
        cell.currentTrack = trackArray[indexPath.row]
        let artistDic = trackArray[indexPath.row]["artist"] as! NSDictionary
        let artist = artistDic["name"] as? String
        let albumDic = trackArray[indexPath.row]["album"] as! NSDictionary
        let albumURL = albumDic["cover_xl"] as! String
        downloadImage(urlImage: albumURL) { (image) in
            cell.thumbnail.image = nil
            cell.thumbnail.image = image
        }
        cell.delegateViewController = self
        cell.trackLabel.text = trackArray[indexPath.row]["title"] as? String
        cell.trackPlaceholder.text = "Title • \(artist!)"
        return cell
    }
    
    
    fileprivate func downloadImage(urlImage: String?, completion: @escaping (UIImage) -> ())  {
        if let imageFromCache = imageCache.object(forKey: urlImage as AnyObject) as? UIImage {
            completion(imageFromCache)
            return
        }
        let url = URL(string: urlImage!)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: urlImage! as AnyObject)
                    completion(image)
                }
            }
        }
        task.resume()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let albumDic = trackArray![index]["album"] as! NSDictionary
        let albumURL = albumDic["cover_xl"] as! String
        downloadImage(urlImage: albumURL) { (image) in
            do {
                let x = try JSONSerialization.data(withJSONObject: self.trackArray![index])
                let track = try JSONDecoder().decode(TrackCodable.self, from: x)
                self.player.loadTrack(songIndex: 0, cover: image, songArray: [track])
            }
            catch  {
                print(error)
            }
        }
    }
    
}
