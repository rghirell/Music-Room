//
//  AlbumTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/13/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit


protocol AlbumLoadDelegate : class {
    func loadAlbum(songIndex: Int, cover: UIImage?, albumName: String?, songArray: [TrackCodable])
}

class AlbumTableViewController: UITableViewController {
   
    var albumTracks: TrackArray? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var albumLoadDelegate: AlbumLoadDelegate!
    var artistName: String?
    var albumCover: UIImage?
    var albumName: String?
    var tracklist: String?
    let trackCellIdentifier = "trackCell"
     let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
       
//        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
//        imageView.contentMode = .scaleAspectFill
//        imageView.image = finalResult?.picture
//        imageView.clipsToBounds = true
//        view.addSubview(imageView)
        
        let parallaxViewFrame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width)
        let x = ParallaxHeaderView(frame: parallaxViewFrame)
        x.imageView.image = albumCover
        self.tableView.tableHeaderView  = x
        title = "Album"
//        tableView.tableHeaderView = imageView
        
        prepareTableView()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let y = UIScreen.main.bounds.size.width - (tableView.contentOffset.y + UIScreen.main.bounds.size.width)
//        let height = min(max(y, 60), 400)
//        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height)
        let headerView = self.tableView.tableHeaderView as! ParallaxHeaderView
        headerView.scrollViewDidScroll(scrollView: scrollView)
    }
    
   
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func downloadTracks() {
        guard let x = tracklist else {  print("No url given"); return }
        let url = URL(string: x)
        guard let urlTask = url else { print("wrong url"); return }
        let task = URLSession.shared.dataTask(with: urlTask) { (data, url, err) in
            if err != nil {
                print(err!)
                return
            }
            guard let data = data else {  print("invalid data"); return }
            do {
                self.albumTracks = try JSONDecoder().decode(TrackArray.self, from: data)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    fileprivate func prepareTableView() {
        tableView.register(TrackTableViewCell.self, forCellReuseIdentifier: trackCellIdentifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.isUserInteractionEnabled = true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: trackCellIdentifier, for: indexPath) as! TrackTableViewCell
        cell.hideImageView(isHidden: true)
        cell.trackLabel.text = albumTracks?.data[indexPath.row].title
        cell.trackPlaceholder.text = artistName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        albumLoadDelegate.loadAlbum(songIndex: indexPath.row, cover: albumCover, albumName: albumName, songArray: (albumTracks?.data)!)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  albumTracks?.data.count ?? 0
    }

}

final class ParallaxHeaderView: UIView {
    
    fileprivate var heightLayoutConstraint = NSLayoutConstraint()
    fileprivate var bottomLayoutConstraint = NSLayoutConstraint()
    fileprivate var containerView = UIView()
    fileprivate var containerLayoutConstraint = NSLayoutConstraint()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let imageView: UIImageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.red
        
        self.addSubview(containerView)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|",
                                                           options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                           metrics: nil,
                                                           views: ["containerView" : containerView]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[containerView]|",
                                                           options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                           metrics: nil,
                                                           views: ["containerView" : containerView]))
        
        containerLayoutConstraint = NSLayoutConstraint(item: containerView,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: self,
                                                       attribute: .height,
                                                       multiplier: 1.0,
                                                       constant: 0.0)
        self.addConstraint(containerLayoutConstraint)
        
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        containerView.addSubview(imageView)
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|",
                                                                    options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                    metrics: nil,
                                                                    views: ["imageView" : imageView]))
        
        bottomLayoutConstraint = NSLayoutConstraint(item: imageView,
                                                    attribute: .bottom,
                                                    relatedBy: .equal,
                                                    toItem: containerView,
                                                    attribute: .bottom,
                                                    multiplier: 1.0,
                                                    constant: 0.0)
        
        containerView.addConstraint(bottomLayoutConstraint)
        
        heightLayoutConstraint = NSLayoutConstraint(item: imageView,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: containerView,
                                                    attribute: .height,
                                                    multiplier: 1.0,
                                                    constant: 0.0)
        
        containerView.addConstraint(heightLayoutConstraint)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        containerLayoutConstraint.constant = scrollView.contentInset.top;
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top);
        containerView.clipsToBounds = offsetY <= 0
        bottomLayoutConstraint.constant = offsetY >= 0 ? 0 : -offsetY / 2
        heightLayoutConstraint.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
    }
}
