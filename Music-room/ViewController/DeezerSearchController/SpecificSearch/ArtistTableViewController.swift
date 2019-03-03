//
//  ArtistTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/25/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Kingfisher

class ArtistTableViewController: ParentTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(ArtistTableViewCell.self, forCellReuseIdentifier: CellIdentifier.artistCell)
        tableView.rowHeight = 120
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.artistCell, for: indexPath) as! ArtistTableViewCell
        let pictureURL = result[indexPath.row]["picture_medium"] as? String
        cell.thumbnail.image = nil
        let url = URL(string: pictureURL!)
        cell.thumbnail.kf.setImage(with: url)
        cell.artistLabel.text = result[indexPath.row]["name"] as? String
        cell.layoutIfNeeded()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ArtistCollectionViewController(collectionViewLayout: StrechyHeader())
        vc.player = player
        vc.albumURL = "https://api.deezer.com/artist/\(result[indexPath.row]["id"] as! Int)/albums"
        vc.artistName = result[indexPath.row]["name"] as? String
        let pictureURL = result[indexPath.row]["picture_xl"] as? String
        vc.headerImage = pictureURL
        vc.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keys.currentTrackViewHeight + 75, right: 0)
        show(vc, sender: self)
    }
}