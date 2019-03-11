//
//  PlaylistPreferenceViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 3/8/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase

protocol PreferenceDelegate : class {
    func changeTableViewInteraction()
    func dismissController()
}

class PlaylistPreferenceViewController: UIViewController {
    
    var playlistUID: String!
    var type: String!
    var ref: DocumentReference!
    private var hasRight = true
    private var isFollowing = true
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var switchPublicPrivate: UISwitch!
    var delegate: PreferenceDelegate! {
        didSet{
            delegate.changeTableViewInteraction()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        // Do any additional setup after loading the view.
    }


    @IBOutlet weak var scroll: UIScrollView!
    @IBAction func `do`(_ sender: UIButton) {
        let vc = AddFriendTableViewController()
    
        vc.playlistUID = self.playlistUID
        vc.type = self.type
        self.addChild(vc)
        guard let vi = view.viewWithTag(1) else { return }
        vc.view.frame = CGRect(x: 0, y: 0, width: vi.frame.width, height: vi.frame.height)
        self.view.viewWithTag(1)!.addSubview(vc.view)
        vc.didMove(toParent: self)
       
    }
    
    @IBAction func close(_ sender: UIButton?) {
        delegate.changeTableViewInteraction()
        view.removeFromSuperview()
    }
    
    @IBOutlet weak var followSwitch: UISwitch!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref = Firestore.firestore().collection(type).document(playlistUID)
        ref.getDocument { (doc, err) in
            guard let data = doc?.data() else {  self.close(nil) ;return }
            guard let owner = data["owner"] as? String else { self.close(nil); return }
            guard let accessibility = data["accessibility"] as? [String: Bool] else { self.close(nil); return }
            guard let playlistStatus = accessibility["public"] else { self.close(nil); return }
            guard let follower = data["follower"] as? [String] else{ self.close(nil); return }
            
            if !follower.contains(Auth.auth().currentUser!.uid) {
                self.isFollowing = false
                self.followSwitch.isOn = false
            }
            if playlistStatus {
                self.switchPublicPrivate.isOn = false
            }
            if owner != Auth.auth().currentUser!.uid {
                self.switchPublicPrivate.isEnabled = false
                self.hasRight = false
                self.deleteButton.isEnabled = false
                self.deleteButton.isHidden = true
            }
        }
        
    }
    
    @IBAction func changePlaylistVisibility(_ sender: UISwitch) {
        if hasRight {
            ref.updateData(["accessibility.public": !sender.isOn])
        }
    }
    
   
    @IBAction func changeFollowStatus(_ sender: UISwitch) {
        if sender.isOn {
            ref.updateData(["follower": FieldValue.arrayUnion([Auth.auth().currentUser!.uid])])
        } else {
            ref.updateData(["follower": FieldValue.arrayRemove([Auth.auth().currentUser!.uid])])
        }
    }
    
    
    @IBAction func DeletePlaylist(_ sender: UIButton) {
        if hasRight {
            let alert = Alert.errorAlert(title: "Delete Playlist", message: "Are you sure you want to delete your playlist ?", cancelButton: true) {
                self.close(nil)
                if self.type == "event" {
                    let refVote = Firestore.firestore().collection("vote").document(self.playlistUID)
                    refVote.delete()
                }
                self.ref.delete()
                self.delegate.dismissController()
            }
            present(alert, animated: true, completion: nil)
        }
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
}
