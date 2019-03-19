//
//  TrackTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/25/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//


class TrackTableViewController: ParentTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: CellIdentifier.trackCell)
        tableView.rowHeight = 120
        tableView.separatorStyle = .none
        tableView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.trackCell, for: indexPath) as! TrackTableViewCell
        cell.currentTrack = result[indexPath.row]
        
        let artistDic = result[indexPath.row]["artist"] as? NSDictionary
        var artist = ""
        if artistDic != nil && artistDic!["name"] as? String != nil {
            artist = artistDic!["name"] as? String ?? ""
        }
        
        cell.trackLabel.text = result[indexPath.row]["title"] as? String ?? ""
        cell.trackPlaceholder.text = "Title • \(artist)"
     
        let albumDic = result[indexPath.row]["album"] as? NSDictionary
        var albumURL = ""
        if albumDic != nil {
            albumURL = albumDic!["cover_medium"] as? String ?? ""
        }
  
        cell.thumbnail.image = nil
        cell.delegateViewController = self
        cell.trackLabel.text = result[indexPath.row]["title"] as? String

        let url = URL(string: albumURL)
        cell.thumbnail.kf.setImage(with: url)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let albumDic = result[indexPath.row]["album"] as? NSDictionary else { return }
        guard let albumURL = albumDic["cover_xl"] as? String else { return }
        do {
            let x = try JSONSerialization.data(withJSONObject: self.result[indexPath.row])
            let track = try JSONDecoder().decode(TrackCodable.self, from: x)
            self.player.loadTrack(songIndex: 0, cover: albumURL, songArray: [track])
        }
        catch  {
            print(error)
            
        }
    }
}
