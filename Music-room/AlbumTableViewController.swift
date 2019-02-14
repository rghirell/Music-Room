//
//  AlbumTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/13/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit



protocol AlbumLoadDelegate : class {
    func loadAlbum(songIndex: Int, cover: UIImage?, albumName: String?, songArray: [TrackCodable])
}

class AlbumTableViewController: UITableViewController {
    var albumTracks: TrackArray? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var albumLoadDelegate: AlbumLoadDelegate!
    var finalResult: MixedModel?
    
    let trackCellIdentifier = "trackCell"
    var tabBar: TabBarController? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    
    func downloadTracks() {
        print("downLoad")
        guard let x = finalResult?.tracklist else {  print("No url given"); return }
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
        cell.trackLabel.text = albumTracks?.data[indexPath.row].title
        cell.trackPlaceholder.text = finalResult?.artist?.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        albumLoadDelegate.loadAlbum(songIndex: indexPath.row, cover: finalResult?.picture, albumName: finalResult?.name, songArray: (albumTracks?.data)!)
        view.superview!.bringSubviewToFront(self.tabBar!.vc.view)
//        UIView.animate(withDuration: 0.2) {
//            self.tabBar?.tabBar.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: (self.tabBar?.tabBar.frame.width)!, height: (self.tabBar?.tabBar.frame.height)!)
//        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  albumTracks?.data.count ?? 0
    }
    


}
