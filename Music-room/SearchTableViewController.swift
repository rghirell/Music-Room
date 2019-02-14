//
//  UserHomeTableViewController.swift
//  
//
//  Created by raphael ghirelli on 1/27/19.
//

import UIKit
import Firebase

//let myGroup = DispatchGroup()


protocol TrackDelegate: class {
    func loadTrack(songIndex: Int, cover: UIImage?, songArray: [TrackCodable])
    func hideTabBar()
}

class SearchTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  UISearchBarDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    let dispatchGroup = DispatchGroup()
    let albumView = AlbumTableViewController()
    
    // MARK: -
    // MARK: CELL IDENTIFIER
    let artistCellIdentifier = "artistCell"
    let trackCellIdentifier = "trackCell"
    let albumCellIdentifier = "albumCell"
    
    // MARK: -
    // MARK: API FETCH
    var fetchedAlbums: AlbumArray?
    var fetchedTracks: TrackArray?
    var fetchedArtist: ArtistArray?
    var finalResult: [MixedModel] = []
    var trackDelegate: TrackDelegate!
    
    fileprivate var tasks = [URLSessionTask]()
    fileprivate var APItasks = [URLSessionTask]()
    fileprivate let imageCache = NSCache<AnyObject, AnyObject>()
    private var tableView: UITableView!
    
    // MARK: -
    var searchController: UISearchController!
    var search = ""
    var runningGroup = 0
    
    
    
    // MARK: -
    // MARK: View Layout
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backButton))
        navigationItem.leftBarButtonItem = button
        updateLeftBarButton(hide: true)
        setupViews()
        setUpSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController!.navigationBar.topItem!.title = "Search"
        //        self.navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(backButton))
        tabBarY = (tabBar?.tabBar.frame.minY)!
    }
    
    var tabBar: TabBarController?
    
    func setupViews() {
        tabBar = self.tabBarController as! TabBarController?
        tabBar!.vc.delegate = self
        tabBar!.vc.view.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        trackDelegate = tabBar
        setupTableView()
        setupAlbumView()
        //        overlay
        view.addSubview(tabBar!.vc.view)
        view.addSubview(albumView.view)
        
    }
    
    func setupAlbumView() {
        albumView.view.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: view.frame.width, height: view.frame.height)
        albumView.tabBar = tabBar
        albumView.albumLoadDelegate = tabBar
    }
    
    func setupTableView() {
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ArtistTableViewCell.self, forCellReuseIdentifier: artistCellIdentifier)
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: trackCellIdentifier)
        tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: albumCellIdentifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keys.currentTrackViewHeight, right: 0)
        view.addSubview(tableView)
    }
    
    func setUpSearchBar() {
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.search = searchText
        finalResult = []
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
    }
    
    func createResultArray(runningGroup: Int) {
        var i = 0
        var final : [MixedModel] = []
        for element in (fetchedArtist?.data)! {
            dispatchGroup.enter()
            downloadImage(urlImage: element.picture_medium!) { (image) in
                final.append(MixedModel(type: element.type, name: element.name, picture: image))
                self.dispatchGroup.leave()
            }
            i += 1
            if i > 2 {
                print("Job done artist")
                break
            }
        }
        i = 0
        for element in (fetchedTracks?.data)! {
            dispatchGroup.enter()
            downloadImage(urlImage: element.album!.cover_xl) { (image) in
                final.append(MixedModel(type: element.type, name: element.title, picture: image, preview: element.preview, album: element.album!, artist: element.artist, track: element))
                self.dispatchGroup.leave()
            }
            i += 1
            if i > 2 {
                print("Job done tracks")
                break
            }
        }
        i = 0
        for element in (fetchedAlbums?.data)! {
            dispatchGroup.enter()
            
            downloadImage(urlImage: element.cover_xl ?? element.artist?.picture_medium) { (image) in
                final.append(MixedModel(type: element.type, name: element.title, picture: image, artist: element.artist!, recordType: element.record_type!, tracklist: element.tracklist))
                self.dispatchGroup.leave()
            }
            i += 1
            if i > 2 {
                print("Job done album")
                break
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("here")
            if runningGroup == self.runningGroup && self.search.count > 0 {
                self.finalResult = final
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: -
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if finalResult.count <= 0 {
            return UITableViewCell()
        }
        switch finalResult[indexPath.row].type {
        case "artist":
            let cell = tableView.dequeueReusableCell(withIdentifier: artistCellIdentifier, for: indexPath) as! ArtistTableViewCell
            cell.thumbnail.image = nil
            cell.artistLabel.text = finalResult[indexPath.row].name
            cell.thumbnail.image = finalResult[indexPath.row].picture
            return cell
        case "track":
            let cell = tableView.dequeueReusableCell(withIdentifier: trackCellIdentifier, for: indexPath) as! TrackTableViewCell
            cell.thumbnail.image = nil
            cell.trackLabel.text = finalResult[indexPath.row].name
            cell.trackPlaceholder.text = "Title • \(finalResult[indexPath.row].artist!.name)"
            cell.thumbnail.image = finalResult[indexPath.row].picture
            return cell
        case "album":
            let cell = tableView.dequeueReusableCell(withIdentifier: albumCellIdentifier, for: indexPath) as! AlbumTableViewCell
            cell.thumbnail.image = finalResult[indexPath.row].picture
            cell.albumLabel.text = finalResult[indexPath.row].name
            cell.albumPlaceholder.text = "\(finalResult[indexPath.row].recordType!.capitalized) • \(finalResult[indexPath.row].artist!.name)"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    var tabBarY: CGFloat = 0
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let final = finalResult[indexPath.row]
        switch final.type {
        case "track":
            playTracks(index: indexPath.row)
        case "album":
            displayAlbum(index: indexPath.row)
        case "artist":
            displayArtist()
        default:
            return
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
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
                print(error?.localizedDescription)
                return
            }
            self.getResult(searchType: searchType, data: data)
            self.dispatchGroup.leave()
        }
        task.resume()
        APItasks.append(task)
    }
    
    func getResult(searchType: String, data: Data?) {
        do {
            switch searchType {
            case "artist":
                let result = try JSONDecoder().decode(ArtistArray.self, from: data!)
                self.fetchedArtist = result
            case "track":
                let result = try JSONDecoder().decode(TrackArray.self, from: data!)
                self.fetchedTracks = result
            case "album":
                let result = try JSONDecoder().decode(AlbumArray.self, from: data!)
                self.fetchedAlbums = result
            default:
                return
            }
        } catch {
            print(searchType,error, data)
        }
    }
    
    fileprivate func downloadImage(urlImage: String?, completion: @escaping (UIImage) -> ())  {
        let url = URL(string: urlImage!)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            // Perform UI changes only on main thread.
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: urlImage! as AnyObject)
                    completion(image)
                }
            }
        }
        task.resume()
    }
    
    
    
}

extension SearchTableViewController: PlayerDelegate {
    func hideNavBar() {
        navigationController?.navigationBar.layer.zPosition = -1
                self.searchController.isActive = false
                self.searchController.searchBar.isHidden = true
    }
    
    func updateView() {
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.layer.zPosition = 0
        self.searchController.searchBar.isHidden = false
    }
    
    func updateLeftBarButton(hide: Bool) {
        navigationItem.leftBarButtonItem?.tintColor = hide ? .clear : .black
        navigationItem.leftBarButtonItem?.isEnabled = hide ? false : true
    }
    
    func playTracks(index: Int) {
        trackDelegate.loadTrack(songIndex: 0, cover: finalResult[index].picture, songArray: [finalResult[index].track!])
//        self.view.bringSubviewToFront(self.tabBar!.vc.view)
//        trackDelegate.hideTabBar()
    }
    
    @objc func backButton() {
        self.navigationController!.navigationBar.topItem!.title = "Search"
        albumView.albumTracks = nil
        UIView.animate(withDuration: 0.2) {
            self.albumView.view.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
        updateLeftBarButton(hide: true)
//        self.searchController.searchBar.isHidden = false
    }
    
    func displayAlbum(index: Int) {
        albumView.finalResult = finalResult[index]
        albumView.downloadTracks()
        view.bringSubviewToFront(albumView.view)
        updateLeftBarButton(hide: false)
        self.navigationController!.navigationBar.topItem!.title = "Album"
        let x = (tabBar?.tabBar.frame.height)! + (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height
        self.albumView.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: x + keys.currentTrackViewHeight, right: 0)
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn
            , animations: {
                self.searchController.isActive = false
                self.albumView.view.frame = CGRect(x: UIScreen.main.bounds.width, y: (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height, width: self.view.frame.width, height: self.view.frame.height)
        }) { (bool) in
            UIView.animate(withDuration: 0.3, animations: {
                self.albumView.view.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height, width: self.view.frame.width, height: self.view.frame.height)
            })
        }
    }
    
    func displayArtist() {
        print("Artist")
    }
    
    
}



