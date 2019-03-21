//
//  TrackTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/22/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit
import JGProgressHUD

protocol TrackDelegate: class {
    func loadTrack(songIndex: Int, cover: UIImage?, songArray: [TrackCodable])
}

class PlaylistTrackTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate, PreferenceDelegate {
    
    var trackArray: [[String: Any]]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var trackLike = [(key: String, value: [String])]()
    var player: PlayerViewController!
    var ref: DocumentReference? = nil
    var refVote: DocumentReference? = nil
    var playlistID: String!
    var tableView: UITableView!
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.interactionType = .blockAllTouches
        hud.parallaxMode = .alwaysOff
        return hud
    }()
    
    // MARK: -
    // MARK: - View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "more_vert"), style: .plain, target: self, action: #selector(displayPlaylistControls))
        ref = Firestore.firestore().collection("playlist").document(playlistID!)
        ref?.addSnapshotListener({ (data, err) in
            if data?.data() == nil { return }
            let x = data!.get("titles") as! [[String: Any]]
            self.trackArray = x
        })
    }
    
    func dismissController() {
        navigationController!.popViewController(animated: true)
    }
    
    // MARK: -
    // MARK: - TableView setup
    fileprivate func setupTableView() {
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 120
        tableView.allowsSelectionDuringEditing = true
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keys.currentTrackViewHeight, right: 0)
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: CellIdentifier.trackCell)
        view.addSubview(tableView)
    }
    
    // MARK: -
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if trackArray?.count ?? 0 <= 0  && !hud.isVisible {
            tableView.setEmptyMessage("No songs in playlist")
        } else {
            self.tableView.restore()
        }
        return trackArray?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.trackCell, for: indexPath) as! TrackTableViewCell
        guard let trackArray = self.trackArray else { return UITableViewCell() }
        cell.currentTrack = trackArray[indexPath.row]
        let artistDic = trackArray[indexPath.row]["artist"] as? NSDictionary
        var artist = ""
        if artistDic != nil && artistDic!["name"] as? String != nil {
            artist = artistDic!["name"] as? String ?? ""
        }
        cell.delegateViewController = self
        cell.delegate = self
        cell.trackLabel.text = trackArray[indexPath.row]["title"] as? String ?? ""
        cell.trackPlaceholder.text = "Title • \(artist)"
        cell.thumbnail.image = nil
        let albumDic = trackArray[indexPath.row]["album"] as? NSDictionary
        var albumURL = ""
        if albumDic != nil {
            albumURL = albumDic!["cover_xl"] as? String ?? ""
        }
        let url = URL(string: albumURL)
        cell.thumbnail.kf.setImage(with: url)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.trackArray?.remove(at: indexPath.row)
            self.ref?.updateData(["titles" : self.trackArray!])
        }
        deleteAction.image = UIImage(named: "delete")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    @objc private func displayPlaylistControls() {
        let vc = PlaylistPreferenceViewController(nibName: "PlaylistPreferenceViewController", bundle: Bundle.main)
        vc.delegate = self
        self.addChild(vc)
        vc.playlistUID = playlistID
        vc.type = "playlist"
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    func changeTableViewInteraction() {
        navigationItem.rightBarButtonItem?.isEnabled = !navigationItem.rightBarButtonItem!.isEnabled
        tableView.isScrollEnabled = !tableView.isScrollEnabled
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let albumDic = trackArray![index]["album"] as! NSDictionary
        let albumURL = albumDic["cover_xl"] as! String
        tableView.deselectRow(at: indexPath, animated: true)
        do {
            let x = try JSONSerialization.data(withJSONObject: self.trackArray![index])
            let track = try JSONDecoder().decode(TrackCodable.self, from: x)
            self.player.loadTrack(songIndex: 0, cover: albumURL, songArray: [track])
        }
        catch  {
            print(error)
        }
    }
    
}
