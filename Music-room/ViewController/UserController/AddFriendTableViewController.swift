//
//  AddFriendTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 3/8/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase

struct Friend {
    var uid: String
    var name: String
    var isSelected = false
    
    init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }
}

class AddFriendTableViewController: UITableViewController, HeadViewDelegate {

    var friendsUID = [String]() {
        didSet {
            getDisplayName()
        }
    }
    
    var friends = [Friend]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var playlistUID: String!
    var type: String!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getFriends()
    }
    
    
    fileprivate func setupTableView() {
        let header = HeadView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        header.delegate = self
        tableView.rowHeight = 50
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "custom")
        tableView.tableHeaderView = header
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends.count
    }
    
    private func getFriends() {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).getDocument { (doc, err) in
            guard let doc = doc else { return }
            guard let data = doc.data() else { return }
            guard let friendsUID =  data["friends"] else { return }
            self.friendsUID = friendsUID as! [String]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "custom", for: indexPath)
        cell.textLabel?.text = friends[indexPath.row].name
        cell.accessoryType = friends[indexPath.row].isSelected ? .checkmark : .none
        return cell
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        friends[indexPath.row].isSelected = !friends[indexPath.row].isSelected
    }
    
    func save() {
        var selectedFriend = [String]()
        for friend in friends {
            if friend.isSelected {
                selectedFriend.append(friend.uid)
            }
        }
        let ref = Firestore.firestore().collection(type).document(playlistUID)
        ref.updateData(["follower": FieldValue.arrayUnion(selectedFriend)])
        self.view.removeFromSuperview()
    }
    
    func back() {
        view.removeFromSuperview()
    }
    
    
    
}

protocol HeadViewDelegate: class {
    func save()
    func back()
}

final fileprivate class HeadView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var delegate: HeadViewDelegate!
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("CANCEL", for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("SAVE", for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.backgroundColor = #colorLiteral(red: 0, green: 0.526463449, blue: 1, alpha: 1)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stackView = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 5
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
    }
    
    @objc private func save() {
        delegate.save()
    }
    @objc private func cancel() {
        delegate.back()
    }
    
}
