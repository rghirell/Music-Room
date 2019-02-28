//
//  ArtistCollectionViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/19/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

class ArtistCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    fileprivate let cellID = "cellID"
    fileprivate let headerId = "headerId"
    fileprivate let padding: CGFloat = 16
    fileprivate var ratio: CGFloat = 0
 
    var artistName: String?
    var player: PlayerViewController!
    

    fileprivate let imageCache = NSCache<AnyObject, AnyObject>()
    var albumURL: String? {
        didSet {
            downloadAlbums()
        }
    }
    
    var albumResult: [AlbumCodable]? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var headerImage: UIImage?
    let navView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "backWhite"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navView)
        view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(popView), for: .touchUpInside)
        setupCollectionViewLayout()
        setupCollectionView()
        
        
        NSLayoutConstraint.activate([
            navView.widthAnchor.constraint(equalTo: view.widthAnchor),
            navView.topAnchor.constraint(equalTo: view.topAnchor),
            navView.heightAnchor.constraint(equalToConstant: 90),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            backButton.heightAnchor.constraint(equalToConstant: 25),
            backButton.widthAnchor.constraint(equalTo:backButton.heightAnchor),
            ])
    }
    
    
    fileprivate func setupCollectionViewLayout() {
        if let layout = collectionViewLayout as? StrechyHeader {
            layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navigationController = self.navigationController else { return }
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isHidden = true
        updateCustomNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let navigationController = self.navigationController else { return }
        navigationController.navigationBar.barStyle = .default
        navigationController.navigationBar.isHidden = false
    }
    
    fileprivate func setupCollectionView() {
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .white
        collectionView.register(ArtistCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
    }
    
    
    fileprivate func downloadAlbums() {
        print(albumURL)
        guard let albumURL = self.albumURL else { return }
        let url = URL(string: albumURL)
        guard let request = url else { return }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
            if err != nil {
                print(err!)
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("\(httpResponse.statusCode)")
                let result = jsonHelper.convertJSONToObject(data: data)
                if let _ = result {
                    print(result!["message"])
                }
                return
            }
            do {
                let result = try JSONDecoder().decode(AlbumArray.self, from: data!)
                self.albumResult = result.data
                print(result)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! HeaderView
        header.imageView.image = headerImage
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 300)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumResult?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let element = albumResult else { print("1")
            return }
        guard let imageFromCache = imageCache.object(forKey: element[indexPath.row].cover_big as AnyObject) as? UIImage  else {
            return }
        if element.indices.contains(indexPath.row) {
            print("3")
            let el = element[indexPath.row]
            let vc = AlbumDetailsTableViewController()
            vc.artistName = self.artistName
            vc.player = player
            vc.albumCover = imageFromCache
            vc.albumName = el.title
            vc.tracklist = el.tracklist
            vc.downloadTracks()
            vc.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keys.currentTrackViewHeight, right: 0)
            show(vc, sender: self)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ArtistCollectionViewCell
        downloadImage(urlImage: albumResult![indexPath.row].cover_big) { (image) in
            cell.coverCollectionView.image = nil
            cell.coverCollectionView.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width / 2 - 30 , height: view.frame.width / 2 - 30)
    }
    
    
    fileprivate func downloadImage(urlImage: String?, completion: @escaping (UIImage) -> ())  {
        if let imageFromCache = imageCache.object(forKey: urlImage as AnyObject) as? UIImage {
            print("here")
            completion(imageFromCache)
            return
        }
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
    
    
    private func updateCustomNavBar() {
        navView.alpha = ratio
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let heightOffset = scrollView.contentOffset.y
        if heightOffset > 215 { return }
        ratio = heightOffset / 250
        updateCustomNavBar()
    }
    
    @objc private func popView() {
        print("Here")
        navigationController?.popViewController(animated: true)
    }
    
}

