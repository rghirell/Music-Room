//
//  UserSearchTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/25/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase

class UserSearchTableViewController: UITableViewController {

    private var result: [QueryDocumentSnapshot]? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var search: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        if search == Auth.auth().currentUser?.displayName {
            return
        }
        let ref = Firestore.firestore().collection("users")
        ref.whereField("displayName", isEqualTo: search).getDocuments { (query, err) in
            self.result = query?.documents
        }
    }
    fileprivate func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if result?.count ?? 0 <= 0 {
            tableView.setEmptyMessage("No results")
        } else {
            self.tableView.restore()
        }
        return result?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = result![indexPath.row].get("displayName") as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UserResultViewController(nibName: "FriendView", bundle: Bundle.main)
        vc.uid = result![indexPath.row].documentID
        vc.userInfo = result![indexPath.row]
        vc.name = result![indexPath.row].get("displayName") as? String
        show(vc, sender: self)
    }
    
}
