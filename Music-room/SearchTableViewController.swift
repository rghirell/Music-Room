//
//  UserHomeTableViewController.swift
//  
//
//  Created by raphael ghirelli on 1/27/19.
//

import UIKit
import Firebase
import JGProgressHUD

class SearchTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  UISearchBarDelegate {
   
    let dispatchGroup = DispatchGroup()
    
    // MARK: -
    // MARK: API FETCH
    var fetchedAlbums: SearchRequest<AlbumCodable>?
    var fetchedTracks: SearchRequest<TrackCodable>?
    var fetchedArtist: SearchRequest<ArtistCodable>?
    var result: [[String: Any]] = [[String: Any]]()
    var trackDelegate: TrackDelegate!
    var player: PlayerViewController!

    
    fileprivate var tasks = [URLSessionTask]()
    fileprivate var APItasks = [URLSessionTask]()
    private var tableView: UITableView!
    
    // MARK: -
    var searchBar: UISearchBar!
    var search = ""
    var runningGroup = 0
    
    // MARK: -
    // MARK: View Layout
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setUpSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupViews() {
        setupTableView()
    }
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.interactionType = .blockAllTouches
        hud.parallaxMode = .alwaysOff
        return hud
    }()
    
    func setupTableView() {
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ArtistTableViewCell.self, forCellReuseIdentifier: CellIdentifier.artistCell)
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: CellIdentifier.trackCell)
        tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: CellIdentifier.albumCell)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "redirectCell")
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keys.currentTrackViewHeight, right: 0)
        view.addSubview(tableView)
    }
    
    func setUpSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
    }
    

    
    // MARK: -
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text?.count ?? 0 <= 0 {
            tableView.setEmptyMessage("Search")
            return 0
        }
        self.tableView.restore()
        return result.count + 5
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search = searchBar.text!
        result = []
        hud.show(in: view)
        dispatchGroup.enter()
        fetchFromAPI(searchType: "artist", cancelPreviousSearch: true)
        dispatchGroup.enter()
        fetchFromAPI(searchType: "track", cancelPreviousSearch: false)
        dispatchGroup.enter()
        fetchFromAPI(searchType: "album", cancelPreviousSearch: false)
        dispatchGroup.notify(queue: .main) {
            if self.fetchedArtist != nil && self.fetchedTracks != nil && self.fetchedAlbums != nil {
                self.runningGroup += 1
                self.createResultArray(runningGroup: self.runningGroup)
            }
        }
        searchBar.resignFirstResponder()
    }
    
    private func specialCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "redirectCell", for: indexPath)
        let x = result.count + 5
        switch x - indexPath.row {
        case 5:
            cell.textLabel?.text = "All artists"
        case 4:
            cell.textLabel?.text = "All titles"
        case 3:
            cell.textLabel?.text = "All albums"
        case 2:
            cell.textLabel?.text = "All playlists"
        case 1:
            cell.textLabel?.text = "All users"
        default:
            print("oops")
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func specialCell(type: Int) {
        switch type {
        case 5:
            let vc = ArtistTableViewController()
            vc.player = player
            vc.searchType = "artist"
            vc.search = self.search
            show(vc, sender: self)
        case 4:
            let vc = TrackTableViewController()
            vc.player = player
            vc.searchType = "track"
            vc.search = self.search
            show(vc, sender: self)
        case 3:
            let vc = AlbumTableViewController()
            vc.player = player
            vc.searchType = "album"
            vc.search = self.search
            show(vc, sender: self)
        case 1:
            let vc = UserSearchTableViewController()
            vc.search = self.search
            show(vc, sender: self)
        default:
            print("oops")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= result.count {
            return specialCell(indexPath: indexPath)
        }
        if result.count <= 0 {
            return UITableViewCell()
        }
        switch result[indexPath.row]["type"] as? String {
        case "artist":
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.artistCell, for: indexPath) as! ArtistTableViewCell
            let pictureURL = result[indexPath.row]["picture_medium"] as? String
            cell.thumbnail.image = nil
            cell.artistLabel.text = result[indexPath.row]["name"] as? String
            guard let picURL = pictureURL else { return cell }
            let url = URL(string: picURL)
            cell.thumbnail.kf.setImage(with: url)
            return cell
        case "track":
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.trackCell, for: indexPath) as! TrackTableViewCell
            cell.currentTrack = result[indexPath.row]
            let artistDic = result[indexPath.row]["artist"] as! NSDictionary
            let artist = artistDic["name"] as? String
            let albumDic = result[indexPath.row]["album"] as! NSDictionary
            let albumURL = albumDic["cover_medium"] as? String
            cell.thumbnail.image = nil
            cell.delegateViewController = self
            cell.trackLabel.text = result[indexPath.row]["title"] as? String
            cell.trackPlaceholder.text = "Title • \(artist!)"
            guard let picURL = albumURL else { return cell }
            let url = URL(string: picURL)
            cell.thumbnail.kf.setImage(with: url)
            return cell
        case "album":
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.albumCell, for: indexPath) as! AlbumTableViewCell
            let artistDic = result[indexPath.row]["artist"] as! NSDictionary
            let artist = artistDic["name"] as? String
            let albumName = result[indexPath.row]["record_type"] as? String
            let pictureURL = result[indexPath.row]["cover_medium"] as? String
            cell.albumLabel.text = result[indexPath.row]["title"] as? String
            cell.albumPlaceholder.text = "\(albumName!.capitalized) • \(artist!)"
            cell.thumbnail.image = nil
            guard let picURL = pictureURL else { return cell }
            let url = URL(string: picURL)
            cell.thumbnail.kf.setImage(with: url)
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row >= result.count {
            specialCell(type: (result.count + 5) - indexPath.row)
            return
        }
        let finalType = result[indexPath.row]["type"] as? String
        switch finalType {
        case "track":
            playTracks(index: indexPath.row)
        case "album":
            displayAlbum(index: indexPath.row)
        case "artist":
            displayArtist(index: indexPath.row)
        default:
            return
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
         searchBar.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
   override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: -
    // MARK: APICalls
    fileprivate func fetchFromAPI(searchType: String, cancelPreviousSearch: Bool) {
        if (cancelPreviousSearch) {
            APItasks.forEach {tasks in
                tasks.cancel()
                
            }
        }
        APItasks = []
        if search.count <= 0 {
            fetchedArtist = nil
            fetchedTracks = nil
            fetchedAlbums = nil
            dispatchGroup.leave()
            Helpers.dismissHud(hud, text: "", detailText: "", delay: 0)
            tableView.reloadData()
            return
        }
        var components = URLComponents(string: "https://api.deezer.com/search/\(searchType)")
        components?.queryItems = [
            URLQueryItem(name: "q", value: self.search),
        ]
        let url = components?.url
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                self.dispatchGroup.leave()
                print(error!.localizedDescription)
                return
            }
            guard let data = data else { self.dispatchGroup.leave() ;return}
            self.getResult(searchType: searchType, data: data)
            self.dispatchGroup.leave()
        }
        task.resume()
        APItasks.append(task)
    }
    
    func getResult(searchType: String, data: Data) {
        do {
            switch searchType {
            case "artist":
                let result = try JSONDecoder().decode(SearchRequest<ArtistCodable>.self, from: data)
                self.fetchedArtist = result
            case "track":
                let result = try JSONDecoder().decode(SearchRequest<TrackCodable>.self, from: data)
                self.fetchedTracks = result
            case "album":
                let result = try JSONDecoder().decode(SearchRequest<AlbumCodable>.self, from: data)
                self.fetchedAlbums = result
            default:
                return
            }
        } catch {
            Helpers.dismissHud(hud, text: "", detailText: "", delay: 0)
            print(error)
        }
    }
}

extension SearchTableViewController {
    
    func playTracks(index: Int) {
        guard let albumDic = result[index]["album"] as? NSDictionary else { return }
        let albumURL = albumDic["cover_xl"] as? String  ?? ""
        do {
            let x = try JSONSerialization.data(withJSONObject: self.result[index])
            let track = try JSONDecoder().decode(TrackCodable.self, from: x)
            self.player.loadTrack(songIndex: 0, cover: albumURL, songArray: [track])
        }
        catch  {
            print(error)
        }
    }
    
    func displayAlbum(index: Int) {
        let albumView = AlbumDetailsTableViewController()
        let pictureURL = result[index]["cover_xl"] as? String
        albumView.player = self.player
        albumView.albumCoverURL = pictureURL
        do {
            let x = try JSONSerialization.data(withJSONObject: self.result[index])
            let album = try JSONDecoder().decode(AlbumCodable.self, from: x)
            albumView.artistName = album.artist?.name
            albumView.albumName = album.title
            albumView.tracklist = album.tracklist
        }
        catch  {
            print(error)
        }
        show(albumView, sender: self)
    }
    
    func displayArtist(index: Int) {
        let vc = ArtistCollectionViewController(collectionViewLayout: StrechyHeader())
        vc.player = player
        vc.albumURL = "https://api.deezer.com/artist/\(result[index]["id"] as? Int ?? 0)/albums"
        vc.artistName = result[index]["name"] as? String
        let pictureURL = result[index]["picture_xl"] as? String
        if pictureURL == nil {
            let alert = Alert.errorAlert(title: "Error", message: "Wrong data were fetch from the server")
            present(alert, animated: true, completion: nil)
            return
        }
        vc.headerImage = pictureURL
        vc.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keys.currentTrackViewHeight + 75, right: 0)
        show(vc, sender: self)
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= result.count {
            return 60
        }
        return 120
    }
    
    
    func createResultArray(runningGroup: Int) {
        if let artistData = fetchedArtist?.data {
            for (index, element) in artistData.enumerated() {
                result.append(element.dictionary)
                if index > 2 {
                    break
                }
            }
        }
        if let trackData = fetchedTracks?.data {
            for (index, element) in trackData.enumerated() {
                result.append(element.dictionary)
                if index > 2 {
                    break
                }
            }
        }
        if let albumData = fetchedAlbums?.data {
            for (index, element) in albumData.enumerated() {
                result.append(element.dictionary)
                if index > 2 {
                    break
                }
            }
        }
        DispatchQueue.main.async {
            if runningGroup == self.runningGroup && self.search.count > 0 {
                Helpers.dismissHud(self.hud, text: "", detailText: "", delay: 0)
                self.fetchedAlbums = nil
                self.fetchedTracks = nil
                self.fetchedArtist = nil
                self.tableView.reloadData()
            }
        }
    }
}
