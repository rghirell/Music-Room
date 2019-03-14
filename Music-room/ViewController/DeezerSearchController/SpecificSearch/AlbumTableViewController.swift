//
//  AlbumTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/25/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

class AlbumTableViewController: ParentTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: CellIdentifier.albumCell)
        tableView.rowHeight = 120
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.albumCell, for: indexPath) as! AlbumTableViewCell
        let artistDic = result[indexPath.row]["artist"] as! NSDictionary
        let artist = artistDic["name"] as? String
        let albumName = result[indexPath.row]["record_type"] as? String
        let pictureURL = result[indexPath.row]["cover_medium"] as? String
        cell.thumbnail.image = nil
        if pictureURL != nil {
            let url = URL(string: pictureURL!)
            cell.thumbnail.kf.setImage(with: url)
        }
        cell.albumLabel.text = result[indexPath.row]["title"] as? String
        cell.albumPlaceholder.text = "\(albumName!.capitalized) • \(artist!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let albumView = AlbumDetailsTableViewController()
        let pictureURL = result[indexPath.row]["cover_big"] as? String
        albumView.player = self.player
        albumView.albumCoverURL = pictureURL
        do {
            let x = try JSONSerialization.data(withJSONObject: self.result[indexPath.row])
            let album = try JSONDecoder().decode(AlbumCodable.self, from: x)
            albumView.artistName = album.artist?.name
            albumView.albumName = album.title
            albumView.tracklist = album.tracklist
        }
        catch  {
            print(error)
        }
        albumView.downloadTracks()
        albumView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keys.currentTrackViewHeight, right: 0)
        self.show(albumView, sender: self)
        
        
    }
    

    
    


}
