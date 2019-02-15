//
//  PlaylistTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/15/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import MapKit



class PlaylistTableViewController: UITableViewController, CLLocationManagerDelegate {

    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var playlistResult = [Playlist]() {
        didSet {
            tableView.reloadData()
        }
    }
    let playlistCellIdentifier = "playlistCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: playlistCellIdentifier)
        locManager.requestWhenInUseAuthorization()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        getPlaylist()
        tableView.rowHeight = 80
    }

    // MARK: - Table view data source

    fileprivate func getPlaylist() {
        let dispatch = DispatchGroup()
        var finalResult: [Playlist]?
        var finalResultEvent: [Playlist]?
        
        guard let currentLocation = locManager.location else {
            print("could'nt get location")
            return
        }
        let timeStamp = NSDate().timeIntervalSince1970.description.split(separator: ".")[0]
        let queryItems = [
            URLQueryItem(name: "end", value: "\(timeStamp)"),
            URLQueryItem(name: "lon", value: "\(currentLocation.coordinate.longitude)"),
            URLQueryItem(name: "lat", value: "\(currentLocation.coordinate.latitude)")
        ]
        dispatch.enter()
        let _: [Playlist]? = FirebaseManager.getRequestWithToken(url: FirebaseManager.PlaylistUrl.event, queryItem: queryItems) { (result) in
            guard let res = result else { return }
            finalResultEvent = res
            dispatch.leave()
        }
        dispatch.enter()
        let _: [Playlist]? = FirebaseManager.getRequestWithToken(url: FirebaseManager.PlaylistUrl.allPlaylist, queryItem: nil) { (result) in
            guard let res = result else { return }
            finalResult = res
            dispatch.leave()
        }
        dispatch.notify(queue: .main) {
            if finalResult != nil {
                for (index, element) in finalResult!.enumerated() {
                    self.playlistResult.append(element)
                }
            }
            if finalResultEvent != nil {
                for (index, element) in finalResultEvent!.enumerated() {
                    self.playlistResult.append(element)
                }
            }
        }

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return playlistResult.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: playlistCellIdentifier, for: indexPath)
        cell.textLabel?.text = playlistResult[indexPath.row].Name
        return cell
    }


}
