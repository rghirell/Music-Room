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
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.albumCell, for: indexPath) as! AlbumTableViewCell
        cell.accessoryType = .disclosureIndicator
        let artistDic = result[indexPath.row]["artist"] as! NSDictionary
        let artist = artistDic["name"] as? String
        let albumName = result[indexPath.row]["record_type"] as? String
        let pictureURL = result[indexPath.row]["cover_medium"] as? String
        cell.thumbnail.image = nil
        if pictureURL != nil {
            downloadImage(urlImage: pictureURL) { (image) in
                cell.thumbnail.image = image
            }
        }
        cell.albumLabel.text = result[indexPath.row]["title"] as? String
        cell.albumPlaceholder.text = "\(albumName!.capitalized) • \(artist!)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
    }
    

    
    


}
