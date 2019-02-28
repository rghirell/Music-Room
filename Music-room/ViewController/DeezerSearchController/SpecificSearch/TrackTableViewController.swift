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
        tableView.rowHeight = 120
        tableView.separatorStyle = .none
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50)
        tableView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.trackCell, for: indexPath) as! TrackTableViewCell
        cell.currentTrack = result[indexPath.row]
        let artistDic = result[indexPath.row]["artist"] as! NSDictionary
        let artist = artistDic["name"] as? String
        let albumDic = result[indexPath.row]["album"] as! NSDictionary
        let albumURL = albumDic["cover_medium"] as! String
        cell.thumbnail.image = nil
        downloadImage(urlImage: albumURL) { (image) in
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
//        cell.contentView.layer.masksToBounds = true
//        let radius = cell.contentView.layer.cornerRadius
//        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    
}
