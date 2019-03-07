//
//  AddToPlaylistTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/22/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase

class AddToPlaylistTableViewController: UITableViewController {

    var isEventPlaylist = true {
        didSet{
            getPlaylist()
        }
    }
    
    var isRegularPlaylist = true {
        didSet {
            getPlaylist()
        }
    }
    
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.playlistCell)
        tableView.rowHeight = 80
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
        ref.whereField("follower", arrayContains: Auth.auth().currentUser?.uid).getDocuments(completion: { (query, err) in
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
        ref.whereField("follower", arrayContains: Auth.auth().currentUser?.uid).getDocuments(completion: { (query, err) in
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
        if isEventPlaylist {
            ref = Firestore.firestore().collection("event").document(playlistResult[indexPath.row].documentID)
            let vote = Firestore.firestore().collection("vote").document(playlistResult[indexPath.row].documentID)
            let x = String(track!["id"] as! Int)
            vote.updateData([x: []])
        } else { ref = Firestore.firestore().collection("playlist").document(playlistResult[indexPath.row].documentID) }
        
        ref.updateData(["titles": FieldValue.arrayUnion([track!])]) { (err) in
            if err != nil {
                let alert = Alert.errorAlert(title: "Error", message: "Couldn't add it to the playlist")
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
 

}
