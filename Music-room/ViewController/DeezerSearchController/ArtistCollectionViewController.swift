//
//  ArtistCollectionViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/19/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import JGProgressHUD

class ArtistCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    fileprivate let cellID = "cellID"
    fileprivate let headerId = "headerId"
    fileprivate let padding: CGFloat = 16
    fileprivate var ratio: CGFloat = 0
 
    var artistName: String? {
        didSet {
            artistLabel.text = artistName
        }
    }
    var player: PlayerViewController!
    
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
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.interactionType = .blockAllTouches
        hud.parallaxMode = .alwaysOff
        return hud
    }()
    
    var headerImage: String?
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
    
    let artistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    // MARK: -
    // MARK: - View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewLayout()
        setupCollectionView()
        setupView()
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
    
    @objc private func popView() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: -
    // MARK: - View layout setup
    fileprivate func setupView() {
        view.addSubview(navView)
        navView.addSubview(artistLabel)
        view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(popView), for: .touchUpInside)
        var navHeight: CGFloat = 85.0
        let screenSize = UIScreen.main.bounds
        if screenSize.height <= 700 {
            navHeight = 65
        }
        NSLayoutConstraint.activate([
            navView.widthAnchor.constraint(equalTo: view.widthAnchor),
            navView.topAnchor.constraint(equalTo: view.topAnchor),
            navView.heightAnchor.constraint(equalToConstant: navHeight),
            navView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            artistLabel.centerXAnchor.constraint(equalTo: navView.centerXAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: navView.trailingAnchor, constant: -20),
            artistLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: -20),
            artistLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
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

    fileprivate func setupCollectionView() {
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .white
        collectionView.register(ArtistCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
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
    
    // MARK: -
    fileprivate func downloadAlbums() {
        hud.show(in: self.collectionView)
        guard let album = self.albumURL else { hud.dismiss(); return }
        let url = URL(string: album)
        guard let request = url else { hud.dismiss(); return }
        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
            if err != nil {
                print(err!)
                self.dismissHud()
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                self.dismissHud()
                print("\(httpResponse.statusCode)")
                let result = jsonHelper.convertJSONToObject(data: data)
                if let _ = result {
                    print(result!["message"] as Any)
                }
                return
            }
            guard let data = data else { self.hud.dismiss(); return }
            do {
                let result = try JSONDecoder().decode(SearchRequest<AlbumCodable>.self, from: data)
                self.dismissHud()
                self.albumResult = result.data
            } catch {
                self.dismissHud()
                print(error)
            }
        }
        task.resume()
    }
    
    
    private func dismissHud() {
        DispatchQueue.main.async {
            self.hud.dismiss()
        }
    }
}

extension ArtistCollectionViewController {
    // MARK: -
    // MARK: - CollectionView datasource/delegate
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! HeaderView
        guard let headerImage = headerImage else { return header }
        let url = URL(string: headerImage)
        header.imageView.kf.indicatorType = .activity
        header.imageView.kf.setImage(with: url)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: UIScreen.main.bounds.height / 3)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumResult?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let element = albumResult else { return }
        if element.indices.contains(indexPath.row) {
            let el = element[indexPath.row]
            let vc = AlbumDetailsTableViewController()
            vc.artistName = self.artistName
            vc.player = player
            vc.albumCoverURL = element[indexPath.row].coverBig
            vc.albumName = el.title
            vc.tracklist = el.tracklist
            show(vc, sender: self)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ArtistCollectionViewCell
        cell.coverCollectionView.image = nil
        guard let picURL = albumResult![indexPath.row].coverMedium else { return cell }
        let url = URL(string: picURL)
        cell.coverCollectionView.kf.indicatorType = .activity
        cell.coverCollectionView.kf.setImage(with: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width / 2 - 30 , height: view.frame.width / 2 - 30)
    }
}

