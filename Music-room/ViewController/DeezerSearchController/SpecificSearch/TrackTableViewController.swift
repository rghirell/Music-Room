//
//  TrackTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/25/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

class TrackTableViewController: ParentTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: CellIdentifier.trackCell)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.trackCell, for: indexPath) as! TrackTableViewCell
        cell.currentTrack = result[indexPath.row]
        let artistDic = result[indexPath.row]["artist"] as! NSDictionary
        let artist = artistDic["name"] as? String
        let albumDic = result[indexPath.row]["album"] as! NSDictionary
        let albumURL = albumDic["cover_medium"] as! String
        downloadImage(urlImage: albumURL) { (image) in
            cell.thumbnail.image = nil
            cell.thumbnail.image = image
        }
        cell.delegateViewController = self
        cell.trackLabel.text = result[indexPath.row]["title"] as? String
        cell.trackPlaceholder.text = "Title • \(artist!)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albumDic = result[indexPath.row]["album"] as! NSDictionary
        let albumURL = albumDic["cover_xl"] as! String
        downloadImage(urlImage: albumURL) { (image) in
            do {
                let x = try JSONSerialization.data(withJSONObject: self.result[indexPath.row])
                let track = try JSONDecoder().decode(TrackCodable.self, from: x)
                self.player.loadTrack(songIndex: 0, cover: image, songArray: [track])
            }
            catch  {
                print(error)
            }
        }
    }
}
