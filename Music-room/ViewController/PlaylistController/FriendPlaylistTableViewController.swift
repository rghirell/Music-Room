//
//  FriendPlaylistTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 3/9/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import JGProgressHUD

class FriendPlaylistTableViewController: UITableViewController, CLLocationManagerDelegate {

    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var player: PlayerViewController!
    var uid: String!
    var type: String!
    var filtered = false
    
    
    var playlistRes: [QueryDocumentSnapshot]?
    var eventRes: [QueryDocumentSnapshot]?
    var playlistResult = [QueryDocumentSnapshot]() {
        didSet {
            if !filtered {
                filtered = true
                filterResult()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRef()
        title = "Playlist"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.playlistCell)
        locManager.requestWhenInUseAuthorization()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        tableView.rowHeight = 80
    }

    
    private func setRef() {
        let refEvent = Firestore.firestore().collection("event")
        if type == "event" {
            refEvent.whereField("follower", arrayContains: uid!).getDocuments { (query, err) in
                self.eventRes = query?.documents
                self.mergeResult()
            }
        }
        
        if type == "playlist" {
            let refPlaylist = Firestore.firestore().collection("playlist")
            refPlaylist.whereField("follower", arrayContains: uid!).getDocuments { (query, err) in
                self.playlistRes = query?.documents
                self.mergeResult()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    lazy var hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.interactionType = .blockAllTouches
        hud.parallaxMode = .alwaysOff
        return hud
    }()
    
    
    // MARK: - Table view data source
    let dispatch = DispatchGroup()
    var finalResult: [Playlist]?
    var finalResultEvent: [Playlist]?
    
    private func mergeResult() {
        
        if self.playlistRes != nil {
            playlistResult += playlistRes!
        }
        if self.eventRes != nil {
            playlistResult +=  eventRes!
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistResult.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.playlistCell, for: indexPath)
        cell.textLabel?.text = playlistResult[indexPath.row].get("Name") as? String
        return cell
    }
    
    private func filterResult() {
        var x = [QueryDocumentSnapshot]()
        
        for el in playlistResult {
            let access = el.data()["accessibility"] as! [String: Bool]
            let result = access["public"]
            if result == false {
                x.append(el)
            }
        }
        var tmp = playlistResult
        tmp.removeAll(where: { x.contains($0) })
        playlistResult = tmp
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if playlistResult[indexPath.row].data()["pos"] != nil {
            let vc = EventTrackTableViewController()
            let pos = playlistResult[indexPath.row].data()["pos"] as! [String: Any]
            let lat = pos["lat"] as! Double
            let lon = pos["lon"] as! Double
            let radius = playlistResult[indexPath.row].data()["distance"] as! Double
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let currentCenter = CLLocationCoordinate2D(latitude: self.locManager.location!.coordinate.latitude, longitude: self.locManager.location!.coordinate.longitude)
            let x = CLCircularRegion(center: currentCenter, radius: radius * 1000, identifier: "europe")
            vc.player = self.player
            vc.playlistID = playlistResult[indexPath.row].documentID
            vc.isInRadius = x.contains(center)
            
            vc.trackArray = playlistResult[indexPath.row].data()["titles"] as? [[String: Any]]
            show(vc, sender: self)
        } else {
            let vc = PlaylistTrackTableViewController()
            vc.player = self.player
            vc.playlistID = playlistResult[indexPath.row].documentID
            vc.trackArray = playlistResult[indexPath.row].data()["titles"] as? [[String: Any]]
            show(vc, sender: self)
        }
        
    }

}
