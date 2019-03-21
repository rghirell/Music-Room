//
//  EventTrackTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 3/7/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import JGProgressHUD

class EventTrackTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LikeDelegate, PreferenceDelegate {

    var trackArray: [[String: Any]]?
    var trackLike = [(key: String, value: [String])]()
    fileprivate let imageCache = NSCache<AnyObject, AnyObject>()
    var player: PlayerViewController!
    var ref: DocumentReference? = nil
    var refListener: ListenerRegistration? = nil
    var isInRadius = false
    var tableView: UITableView!
    
    var refVote: DocumentReference? = nil
    var refVoteListener: ListenerRegistration? = nil
    var playlistID: String!
    var owner = false
    var canPlay = false
    var trackOrder = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        let ref = Firestore.firestore().collection("event").document(playlistID!)
        ref.getDocument { (doc, err) in
            guard let data = doc?.data() else {   return }
            guard let owner = data["owner"] as? String else { return }
            guard let canPlay = data["can_play"] as? [String] else { return }
            guard let myId = Auth.auth().currentUser?.uid else { return }
            if canPlay.contains(myId) {
                self.canPlay = true
            }
            guard let myUID = Auth.auth().currentUser?.uid else { return }
            if owner == myUID {
                self.owner = true
            }
        }
    }
    
    var flag = 0
    var eventIsFetching = false
    var voteIsFetching = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hud.show(in: view)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "more_vert"), style: .plain, target: self, action: #selector(displayPlaylistControls))
        ref = Firestore.firestore().collection("event").document(playlistID!)
        self.refListener = self.ref?.addSnapshotListener({ (data, err) in
            self.eventIsFetching = true
            self.ref?.getDocument(completion: { (data, err) in
                if data?.data() == nil { return }
                let x = data!.get("titles") as! [[String: Any]]
                self.trackArray = x
                self.eventIsFetching = false
                if !self.voteIsFetching {
                    self.reloadData()
                }
            })
        })
        
        refVote = Firestore.firestore().collection("vote").document(playlistID)
        refVoteListener = refVote?.addSnapshotListener({ (data, err) in
            self.voteIsFetching = true
            self.refVote?.getDocument(completion: { (data, err) in
                guard let data = data?.data() else  { return }
                let x = data as! [String: [String]]
                self.trackLike = x.sorted { $0.value.count > $1.value.count }
                self.voteIsFetching = false
                if !self.eventIsFetching {
                    self.reloadData()
                }
            })
        })
    }
    
    private func reloadData() {
        hud.dismiss()
        
        eventIsFetching = false
        voteIsFetching = false
        if self.trackArray!.count != self.trackLike.count {
            self.dismissController()
        }
        self.trackOrder.removeAll()
        self.tableView.reloadData()
    }

    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.interactionType = .blockAllTouches
        hud.parallaxMode = .alwaysOff
        return hud
    }()
    
    fileprivate func setupTableView() {
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 120
        tableView.allowsSelectionDuringEditing = true
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keys.currentTrackViewHeight, right: 0)
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: CellIdentifier.trackCell)
        view.addSubview(tableView)
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if trackArray?.count ?? 0 <= 0  {
            tableView.setEmptyMessage("No songs in events")
        } else {
            self.tableView.restore()
        }
        return trackArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.trackCell, for: indexPath) as! TrackTableViewCell
        if !isInRadius {
            cell.isUserInteractionEnabled = false
        }
        var index = indexPath.row
        guard let trackArray = self.trackArray else { return UITableViewCell() }
        if trackLike.count <= 0 {
            return UITableViewCell()
        }
        if indexPath.row >= trackLike.count {
            index = indexPath.row
        } else {
            let tmp = trackArray.firstIndex(where: { (y) -> Bool in
                return y["id"] as? Int == Int(trackLike[indexPath.row].key)
            })
            if tmp == nil {
                dismissController()
            } else {
                index = tmp!
            }
        }
        trackOrder.append(index)
        cell.liked = trackLike[indexPath.row].value.contains(Auth.auth().currentUser!.uid)
        cell.likeDelegate = self
        cell.currentTrack = trackArray[index]
        cell.hideThumbButton(isHidden: false)
        let artistDic = trackArray[index]["artist"] as? NSDictionary
        var artist = ""
        if artistDic != nil && artistDic!["name"] as? String != nil {
            artist = artistDic!["name"] as? String ?? ""
        }
        cell.delegateViewController = self
        cell.trackLabel.text = trackArray[index]["title"] as? String ?? ""
        cell.trackPlaceholder.text = "Title • \(artist)"
        cell.thumbnail.image = nil 
        let albumDic = trackArray[index]["album"] as? NSDictionary
        var albumURL = ""
        if albumDic != nil {
            albumURL = albumDic!["cover_xl"] as? String ?? ""
        }
        downloadImage(urlImage: albumURL) { (image) in
            cell.thumbnail.image = image
        }
        return cell
    }
    
    fileprivate func downloadImage(urlImage: String, completion: @escaping (UIImage) -> ())  {
        if let imageFromCache = imageCache.object(forKey: urlImage as AnyObject) as? UIImage {
            completion(imageFromCache)
            return
        }
        let ur = URL(string: urlImage)
        guard let url = ur else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: urlImage as AnyObject)
                    completion(image)
                }
            }
        }
        task.resume()
    }
    
    @objc private func displayPlaylistControls() {
        let vc = PlaylistPreferenceViewController(nibName: "PlaylistPreferenceViewController", bundle: Bundle.main)
        vc.delegate = self
        self.addChild(vc)
        vc.playlistUID = playlistID
        vc.type = "event"
        vc.view.frame = self.view.frame
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    func changeTableViewInteraction() {
        navigationItem.rightBarButtonItem?.isEnabled = !navigationItem.rightBarButtonItem!.isEnabled
        tableView.isScrollEnabled = !tableView.isScrollEnabled
    }
    
    func dismissController() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refListener?.remove()
        refVoteListener?.remove()
    }
    
    func updatelikes(track: [String : Any], like: Bool) {
        let x = String(track["id"] as! Int)
        switch like {
        case true:
            refVote!.updateData([x: FieldValue.arrayUnion([Auth.auth().currentUser!.uid])])
        case false:
            refVote!.updateData(([x: FieldValue.arrayRemove([Auth.auth().currentUser!.uid])]))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isInRadius {
            let alert = Alert.errorAlert(title: "Warning", message: "You won't be able to interact with this event as you are not in the correct radius")
            present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !owner && !canPlay {
            return
        }
        let index = trackOrder[indexPath.row]
        let albumDic = trackArray![index]["album"] as! NSDictionary
        let albumURL = albumDic["cover_xl"] as? String ?? ""
        tableView.deselectRow(at: indexPath, animated: true)
        do {
            let x = try JSONSerialization.data(withJSONObject: self.trackArray![index])
            let track = try JSONDecoder().decode(TrackCodable.self, from: x)
            self.player.loadTrack(songIndex: 0, cover: albumURL, songArray: [track])
        }
        catch  {
            print(error)
        }
    }

}
