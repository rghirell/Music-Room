//
//  PlaylistTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/15/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import MapKit
import JGProgressHUD
import Firebase



class PlaylistTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    var locManager = CLLocationManager()
    var player: PlayerViewController!
    
    var playlistRes: [QueryDocumentSnapshot]?
    var eventRes: [QueryDocumentSnapshot]?
    var providerID: String!
    var playlistResult = [QueryDocumentSnapshot]() {
        didSet {
            hud.dismiss(animated: true)
            tableView.reloadData()
        }
    }
    var userUID: String!
    
    lazy var newButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPlaylistHub))
        button.tintColor = .black
        return button
    }()
    
    let accountButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "account"), for: .normal)
        return button
    }()
    
    lazy var textFieldPlaylist: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Playlist name"
        return textField
    }()
    var tableView: UITableView!
    
    
    //MARK: -
    //MARK: - View Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.requestWhenInUseAuthorization()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
       
        locManager.startUpdatingLocation()
        decode()
        setNavBarButton()
        title = "Playlist"
        setTableView()
    }
    
    private func setNavBarButton() {
        navigationItem.rightBarButtonItem = newButton
        accountButton.addTarget(self, action: #selector(showAccount), for: .touchUpInside)
        accountButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        accountButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        let barButton = UIBarButtonItem(customView: accountButton)
        navigationItem.leftBarButtonItem = barButton
    }
    
    fileprivate func setTableView() {
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keys.currentTrackViewHeight, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier.playlistCell)
        tableView.rowHeight = 80
        view.addSubview(tableView)
    }
    
    @objc func showAccount() {
        guard let provider = providerID else { return }
        let userAccountVC = UserAccountViewController(nibName: "UserView", bundle: Bundle.main)
        userAccountVC.providerID = provider
        let nc = UINavigationController(rootViewController: userAccountVC)
        present(nc, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let userUID = Auth.auth().currentUser?.uid else {
            do {
                try Auth.auth().signOut()
            } catch  {
                print(error)
            }
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.userUID = userUID
    }
    
    //MARK: -
    //MARK: - Location Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        setRef()
        locManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        setRef()
        locManager.stopUpdatingLocation()
    }

    // MARK: -
    // MARK: - Playlist Setup
    private var flag = 0
    var eventIsFetching = false
    var playlistIsFetching = false
    private func setRef() {
        let refEvent = Firestore.firestore().collection("event")
        refEvent.whereField("follower", arrayContains: userUID).addSnapshotListener { (query, err) in
            self.eventIsFetching = true
            self.hud.show(in: self.view)
            self.eventRes = query?.documents
            self.eventIsFetching = false
            if self.playlistIsFetching {
                return
            }
            self.mergeResult()
        }
        let refPlaylist = Firestore.firestore().collection("playlist")
        refPlaylist.whereField("follower", arrayContains: userUID).addSnapshotListener { (query, err) in
            self.playlistIsFetching = true
            self.hud.show(in: self.view)
            self.playlistRes = query?.documents
            self.playlistIsFetching = false
            if self.eventIsFetching {
                return
            }
            self.mergeResult()
        }
    }
    
    @objc func addPlaylistHub() {
        let alert = UIAlertController(title: "Playlist type", message: "What kind of playlist do you want to create", preferredStyle: .alert)
        let event = UIAlertAction(title: "Event", style: .default) { (_) in
            self.addEventPlaylist()
        }
        let playlist = UIAlertAction(title: "Playlist", style: .default) { (_) in
            self.addRegularPlaylist()
        }
        alert.addAction(playlist)
        alert.addAction(event)
        present(alert, animated: true, completion: nil)
    }
    
    lazy var hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.interactionType = .blockAllTouches
        hud.parallaxMode = .alwaysOff
        return hud
    }()
    
    private func addRegularPlaylist() {
        let alert =  Alert.alert(style: .alert, title: "Add Playlist", message: "Add new playlist", textFields: [textFieldPlaylist]) { (name) in
            if name == nil || name![0].count <= 0 {
                let alert = Alert.errorAlert(title: "Error", message: "No playlist name was provided !")
                self.present(alert, animated: true, completion: nil)
            } else {
                let queryItems = [
                    URLQueryItem(name: "playlistName", value: name![0]),
                    URLQueryItem(name: "genre", value: ""),
                    ]
                DispatchQueue.main.async {
                    self.hud.textLabel.text = "Creating Playlist ..."
                    self.hud.show(in: self.view)
                }
                FirebaseManager.postRequestWithToken(url: FirebaseManager.PlaylistUrl.addPlaylist, queryItem: queryItems, data: nil, result: { (code) in
                    self.checkStatusCode(code: code)
                })
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addEventPlaylist() {
        let alert =  Alert.alert(style: .alert, title: "Add Event", message: "Add Event playlist", textFields: [textFieldPlaylist]) { (name) in
            if name == nil || name![0].count <= 0 {
                let alert = Alert.errorAlert(title: "Error", message: "No playlist name was provided !")
                self.present(alert, animated: true, completion: nil)
            } else {
               
                let timeStamp = Int(NSDate().timeIntervalSince1970.rounded())
                guard let currentLocation = self.locManager.location else {
                    print("could'nt get location")
                    return
                }
                let event = EventPlaylistCreation(Name: name![0], genre: "", start: timeStamp, end: timeStamp + 20000, lon: currentLocation.coordinate.longitude ,lat: currentLocation.coordinate.latitude ,distance: 5)
                do {
                    print(event)
                    let body = try JSONEncoder().encode(event)
                    DispatchQueue.main.async {
                        self.hud.textLabel.text = "Creating Event ..."
                        self.hud.show(in: self.view)
                    }
                    FirebaseManager.postRequestWithToken(url: FirebaseManager.PlaylistUrl.addEvent, queryItem: nil, data: body, result: { (code) in
                        self.checkStatusCode(code: code)
                    })
                } catch {
                    print(error)
                }
            }
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func checkStatusCode(code: Int) {
        DispatchQueue.main.async {
            self.hud.dismiss()
            if code != 200 {
                let alert = Alert.errorAlert(title: "Error", message: "Couldn't create new playlist")
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    var finalResult: [Playlist]?
    var finalResultEvent: [Playlist]?
    
    private func mergeResult() {
        self.playlistIsFetching = false
        self.eventIsFetching = false
        var tmp = [QueryDocumentSnapshot]()
        if self.playlistRes != nil {
            tmp += playlistRes!
        }
        if self.eventRes != nil {
            tmp +=  eventRes!
        }
        playlistResult = tmp
    }
    
    // MARK: -
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.playlistCell, for: indexPath)
        cell.textLabel?.text = playlistResult[indexPath.row].get("Name") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if playlistResult[indexPath.row].data()["pos"] != nil {
            guard let location = locManager.location else {
                let alert = Alert.errorAlert(title: "Location Error", message: "Couldn't get your current position, make sure you have enable geolocation on your settings")
                present(alert, animated: true, completion: nil)
                return
            }
            let vc = EventTrackTableViewController()
            let pos = playlistResult[indexPath.row].data()["pos"] as! [String: Any]
            let lat = pos["lat"] as! Double
            let lon = pos["lon"] as! Double
            let radius = playlistResult[indexPath.row].data()["distance"] as! Double
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let currentCenter = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let x = CLCircularRegion(center: currentCenter, radius: radius * 1000, identifier: "europe")
            vc.player = self.player
            vc.playlistID = playlistResult[indexPath.row].documentID
            vc.isInRadius = x.contains(center)
            vc.trackArray = playlistResult[indexPath.row].data()["titles"] as? [[String: Any]]
            show(vc, sender: self)
        } else {
            let vc = PlaylistTrackTableViewController()
            vc.player = self.player
            vc.playlistID = playlistResult[indexPath.row].documentID
            vc.trackArray = playlistResult[indexPath.row].data()["titles"] as? [[String: Any]]
            show(vc, sender: self)
        }
    
    }
}

extension PlaylistTableViewController {
    
    //MARK: -
    //MARK: Convert JWT to readable data
    func decode()  {
        Auth.auth().currentUser?.getIDToken(completion: { (token, err) in
            if err != nil {
                return
            }
            let segments = token!.components(separatedBy: ".")
            let x =  self.decodeJWTPart(segments[1]) ?? [:]
            let y = x["firebase"] as! [String: Any]
            self.providerID = y["sign_in_provider"] as? String
        })
        
    }
    
    func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
    
    func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
            let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
                return nil
        }
        return payload
    }
}
