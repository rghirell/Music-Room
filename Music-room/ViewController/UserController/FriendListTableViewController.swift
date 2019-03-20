//
//  FriendListTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 3/9/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase

class FriendListTableViewController: UITableViewController, FriendCellDelegate {

    var friendsUID = [String]() {
        didSet {
            getDisplayName()
        }
    }
    
    var userFriendsUID = [String]()
    
    var userUID: String!
    
    var friends = [Friend]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var playlistUID: String!
    var type: String!
    
    
    // MARK: -
    // MARK: - View setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getFriends()
    }
    
    fileprivate func setupTableView() {
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        let xib = UINib(nibName: "FriendsTableViewCell", bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: CellIdentifier.friendCell)
    }
    
    // MARK: - TableView delegate/data
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friends.count <= 0 {
            tableView.setEmptyMessage("No results")
        }else {
            self.tableView.restore()
        }
        return friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.friendCell, for: indexPath) as! FriendsTableViewCell
        cell.displayName.text = friends[indexPath.row].name
        cell.delegate = self
        cell.isFriend = userFriendsUID.contains(friends[indexPath.row].uid)
        cell.index = indexPath.row
        cell.accessoryType = friends[indexPath.row].isSelected ? .checkmark : .none
        return cell
    }
    
    // MARK: -
    // MARK: - Firebase logic
    private func getFriends() {
        Firestore.firestore().collection("users").document(userUID).getDocument { (doc, err) in
            guard let doc = doc else { return }
            guard let data = doc.data() else { return }
            guard let friendsUID =  data["friends"] else { return }
            self.friendsUID = friendsUID as! [String]
        }
    }
    
    private func getUserFriends() {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).getDocument { (doc, err) in
            guard let doc = doc else { return }
            guard let data = doc.data() else { return }
            guard let friendsUID =  data["friends"] else { return }
            self.userFriendsUID = friendsUID as! [String]
        }
    }
    
    private func getDisplayName() {
        let dispatch = DispatchGroup()
        var x = [Friend]()
        for uid in friendsUID {
            dispatch.enter()
            Firestore.firestore().collection("users").document(uid).getDocument { (doc, err) in
                guard let doc = doc else { return }
                guard let data = doc.data() else { return }
                guard let friendName =  data["displayName"] else { return }
                x.append(Friend(uid: uid, name: friendName as! String))
                dispatch.leave()
            }
        }
        dispatch.notify(queue: .main) {
            self.friends = x
        }
    }
    
    func addOrRemoveFriend(index: Int, add: Bool) {
        let ref = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        if add {
            ref.updateData(["friends": FieldValue.arrayUnion([friends[index].uid])])
        } else {
            ref.updateData(["friends": FieldValue.arrayRemove([friends[index].uid])])
        }
    }
    
}

