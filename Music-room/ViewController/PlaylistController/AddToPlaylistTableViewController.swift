//
//  AddToPlaylistTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/22/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class AddToPlaylistTableViewController: UITableViewController {

    var isEventPlaylist = true
    
    var isRegularPlaylist = true
    
    var userUID: String! {
        didSet {
            getPlaylist()
        }
    }
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.interactionType = .blockAllTouches
        hud.parallaxMode = .alwaysOff
        return hud
    }()
    
    var idTrack = 0
    var track: [String: Any]?
    var playlistRes: [QueryDocumentSnapshot]?
    var eventRes: [QueryDocumentSnapshot]?
    var playlistResult = [QueryDocumentSnapshot]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Cancel", style: .done , target: self, action: #selector(dismissView))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let uid = Auth.auth().currentUser?.uid else { dismiss(animated: true, completion: nil); return }
        userUID = uid
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.playlistCell)
        tableView.rowHeight = 80
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

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
    
    let dispatch = DispatchGroup()
    fileprivate func getPlaylist() {
        if isEventPlaylist {
            dispatch.enter()
            getEventPlaylist()
        }
        if isRegularPlaylist {
            dispatch.enter()
            getRegularPlaylist()
        }
        dispatch.notify(queue: .main) {
            if self.playlistRes != nil {
                for (element) in self.playlistRes! {
                    self.playlistResult.append(element)
                }
            }
            if self.eventRes != nil {
                for (element) in self.eventRes! {
                    self.playlistResult.append(element)
                }
            }
        }
    }
    
    fileprivate func getRegularPlaylist() {
        let ref = Firestore.firestore().collection("playlist")
        ref.whereField("follower", arrayContains: userUID).getDocuments(completion: { (query, err) in
            if err != nil {
                self.dispatch.leave()
                return
            }
            self.dispatch.leave()
            self.playlistRes = query?.documents
        })
    }
    
    fileprivate func getEventPlaylist() {
        let ref = Firestore.firestore().collection("event")
        ref.whereField("follower", arrayContains: userUID).getDocuments(completion: { (query, err) in
            if err != nil {
                self.dispatch.leave()
                return
            }
            self.eventRes = query?.documents
            self.dispatch.leave()
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var ref: DocumentReference
        hud.show(in: self.view)
        if isEventPlaylist {
            ref = Firestore.firestore().collection("event").document(playlistResult[indexPath.row].documentID)
            let vote = Firestore.firestore().collection("vote").document(playlistResult[indexPath.row].documentID)
            guard let track = self.track, let x = track["id"] as? Int else { return }
            let idTrack = String(x)
            self.idTrack = x
            vote.updateData([idTrack: FieldValue.arrayUnion([])]) { (err) in
                if err != nil {
                    let alert = Alert.errorAlert(title: "Error", message: err!.localizedDescription, cancelButton: true, completion: {
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            
        } else { ref = Firestore.firestore().collection("playlist").document(playlistResult[indexPath.row].documentID) }
        
        ref.getDocument { (doc, err) in
            if err != nil {
                let alert = Alert.errorAlert(title: "Error", message: "error")
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            guard let doc = doc?.data()  else { return }
            guard let titles = doc["titles"] as? [[String: Any]] else { return }
            var flag = false
            for element in titles {
                if element["id"] as! Int == self.idTrack {
                    flag = true
                    break
                }
             }
            if !flag {
                ref.updateData(["titles": FieldValue.arrayUnion([self.track!])]) { (err) in
                    if err != nil {
                        let alert = Alert.errorAlert(title: "Error", message: "Couldn't add it to the playlist")
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            } else { self.dismiss(animated: true, completion: nil) }
        }
    }
}
