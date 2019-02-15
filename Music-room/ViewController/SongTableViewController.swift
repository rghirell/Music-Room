//
//  SongTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/1/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase


class SongTableViewController: UITableViewController {

    var titles: [String]?
    var playlistID: String?
    var ref: DocumentReference? = nil
    typealias DeezerObjectListRequest = (_ objectList: DZRObjectList? ,_ error: Error?) -> Void
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true

        
        DZRObject.search(for: .track, withQuery: "origin", requestManager: DZRRequestManager.default(), callback: { (data, error) in
            print(data)
        })
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if titles != nil {
            return titles!.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        cell.textLabel?.text = titles![indexPath.item]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(titles![indexPath.item])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        ref = Firestore.firestore().collection("playlist").document(playlistID!)
        ref?.addSnapshotListener({ (data, err) in
            let x = data!.get("titles") as! NSArray
            self.titles = x as? [String]
            self.tableView.reloadData()
            print(self.titles ?? "nothing")
        })
    
    }
    
 
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("item to move")
        let itemToMove = titles![sourceIndexPath.row]
        titles!.remove(at: sourceIndexPath.row)
        titles!.insert(itemToMove, at: destinationIndexPath.row)
        ref?.updateData(["titles" : titles!])
        tableView.reloadData()
    }

}
