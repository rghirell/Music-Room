//
//  UserResultViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 3/8/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase

class UserResultViewController: UIViewController {
    
    var uid: String!
    var ref: DocumentReference!
    var name: String!
    var userInfo: QueryDocumentSnapshot!
    var friendsArray = [String]() {
        didSet {
            checkFriendRelationship()
        }
    }

    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var showFriendButton: UIButton!
    var isFriend = false {
        didSet {
            updateButtonTitle()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = name {
            displayName.text = name
        } else { displayName.text = "Error" }
        addFriendButton.addTarget(self, action: #selector(addOrRemoveFriend), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        ref = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        ref.getDocument { (doc, err) in
            guard let doc = doc else { return }
            guard let data = doc.data() else { return }
            guard let friends =  data["friends"] else { return }
            self.friendsArray = friends as! [String]
        }
    }

    @IBAction func showFriend(_ sender: UIButton) {
        let vc = FriendListTableViewController()
        vc.userUID = uid
        show(vc, sender: self)
    }
    
    @IBAction func showPublicEvent(_ sender: UIButton) {
        let vc = FriendPlaylistTableViewController()
        vc.type = "event"
        vc.uid = self.uid
        show(vc, sender: self)
    }
    
    @IBAction func showPublicPlaylist(_ sender: UIButton) {
        let vc = FriendPlaylistTableViewController()
        vc.type = "playlist"
        vc.uid = self.uid
        show(vc, sender: self)
    }
    
    
    private func checkFriendRelationship() {
        isFriend = friendsArray.contains(where: { $0 == uid } )
    }
    
    private func updateButtonTitle() {
        let title = isFriend ? "Unfollow" : "Follow"
        addFriendButton.setTitle(title, for: .normal)
    }
    
    @objc private func addOrRemoveFriend() {
        if !isFriend {
            ref.updateData(["friends": FieldValue.arrayUnion([uid])])
            isFriend = true
        } else {
            ref.updateData(["friends": FieldValue.arrayRemove([uid])])
            isFriend = false
        }
    }
    
}
