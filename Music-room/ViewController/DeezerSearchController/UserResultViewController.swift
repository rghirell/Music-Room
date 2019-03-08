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
    var friendsArray = [String]() {
        didSet {
            checkFriendRelationship()
        }
    }

    var isFriend = false {
        didSet {
            updateButtonTitle()
        }
    }
    let addFriendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Follow", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupButton()
        // Do any additional setup after loading the view.
    }
    
    private func setupButton() {
        view.addSubview(addFriendButton)
        addFriendButton.addTarget(self, action: #selector(addOrRemoveFriend), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            addFriendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addFriendButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addFriendButton.widthAnchor.constraint(equalToConstant: 200),
            addFriendButton.heightAnchor.constraint(equalToConstant: 100),
            ])
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
