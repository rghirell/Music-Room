//
//  UserResultViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 3/8/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase

class UserResultViewController: UIViewController,  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var uid: String!
    var ref: DocumentReference!
    var name: String!
    var userInfo: QueryDocumentSnapshot!
    var friendsArray = [String]() {
        didSet {
            checkFriendRelationship()
        }
    }
    var preferences = [String]()
    var buttons = [UIButton]()

    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var showFriendButton: UIButton!
    @IBOutlet weak var publicPlaylistButton: UIButton!
    @IBOutlet weak var publicEventButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isFriend = false {
        didSet {
            updateButtonTitle()
        }
    }

    // MARK: -
    // MARK: - View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setCornerLayer(viewArray: [addFriendButton, showFriendButton, publicEventButton, publicPlaylistButton])
        if let name = name {
            displayName.text = name
        } else { displayName.text = "Error" }
        setupCollectionView()
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
    
    // MARK: -
    // MARK: - View setup
    private func setCornerLayer(viewArray: [UIView]) {
        for element in viewArray {
            element.layer.cornerRadius = 5
            element.layer.borderColor = UIColor.black.cgColor
            element.layer.shadowColor = UIColor.black.cgColor
            element.layer.shadowOffset = CGSize(width: 3, height: 3)
            element.layer.shadowOpacity = 0.4
            element.layer.shadowRadius = 4.0
        }
    }
    
    func createButton(withTitle title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 15
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
        button.isUserInteractionEnabled = false
        button.sizeToFit()
        return button
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
    
    // MARK: -
    // MARK: - CollectionView management
    fileprivate func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 30, bottom: 10, right: 30)
        layout.minimumInteritemSpacing = 8
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = .white
        collectionView.register(TagsCollectionViewCell.self, forCellWithReuseIdentifier: "test")
        guard let preferences = userInfo.data()["pref_music"] as? [String] else { return }
        self.preferences = preferences
        for title in self.preferences {
            self.buttons.append(self.createButton(withTitle: title))
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if preferences.count <= 0 {
            collectionView.setEmptyMessage("No Preferences")
        } else {
            self.collectionView.restore()
        }
        return preferences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "test", for: indexPath) as! TagsCollectionViewCell
        cell.button.setTitle(preferences[indexPath.row], for: .normal)
        cell.isHidden(hide: true)
        cell.backgroundColor = .red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: buttons[indexPath.row].frame.width  , height: buttons[indexPath.row].frame.height)
    }
    
}
