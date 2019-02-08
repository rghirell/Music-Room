//
//  UserHomeTableViewController.swift
//  
//
//  Created by raphael ghirelli on 1/27/19.
//

import UIKit
import Firebase

class UserHomeTableViewController: UITableViewController {
    var numbers = ["One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten","Eleven","Twelve","Four","Five","Six","Seven","Eight","Nine","Ten","Eleven","Four","Five","Six","Seven","Eight","Nine","Ten","Eleven"]
    
    var playlists: [Playlist]?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseEndpoint.getPublicPlaylists { (playlists) in
            self.playlists = playlists
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    @objc func logout() {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        } catch  {
            print(error)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if playlists != nil {
            return playlists!.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath)
        cell.textLabel!.text = playlists![indexPath.item].Name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "SongTableViewController") as! SongTableViewController
//        vc.titles = playlists![indexPath.item].titles
        vc.playlistID = playlists![indexPath.item].id
        navigationController?.pushViewController(vc, animated: true)
    }
    
  

}
