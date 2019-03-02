
//
//  UserAccountViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/15/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import MapKit
import GoogleSignIn



class UserAccountViewController: UIViewController , CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttons.count
    }
    
    let titles = ["Jazz", "Electro", "Rap", "Pop", "Hip-hop", "Rock", "Chill", "Ambiance", "Latino", "Affro", "RnB", "Classique"]
    var buttons = [UIButton]()
    
    func createButton(withTitle title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 15
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
        button.addTarget(self, action: #selector(change), for: .touchUpInside)
        button.sizeToFit()
        return button
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "test", for: indexPath) as! TagsCollectionViewCell
        cell.button.setTitle(titles[indexPath.row], for: .normal)
        cell.backgroundColor = .red
        return cell
    }
    
    @objc func change(sender: UIButton) {
    }
    

    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var collectionView: UICollectionView!
    
    let buttonTest: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Test", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let collectionContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        for title in titles {
            buttons.append(createButton(withTitle: title))
        }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 30, bottom: 10, right: 30)
//        layout.itemSize = CGSize(width: 90, height: 120)
        layout.minimumInteritemSpacing = 8
//        layout.minimumLineSpacing = 20
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = true
        collectionContainer.clipsToBounds = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TagsCollectionViewCell.self, forCellWithReuseIdentifier: "test")
        view.addSubview(buttonTest)
        collectionContainer.addSubview(collectionView)
        view.addSubview(collectionContainer)
        DeezerManager.sharedInstance.loginResult = sessionDidLogin
        buttonTest.addTarget(self, action: #selector(test), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            buttonTest.widthAnchor.constraint(equalToConstant: 50),
            buttonTest.heightAnchor.constraint(equalToConstant: 200),
            collectionContainer.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionContainer.heightAnchor.constraint(equalToConstant: 200),
            collectionView.widthAnchor.constraint(equalTo: collectionContainer.widthAnchor),
            collectionView.heightAnchor.constraint(equalTo: collectionContainer.heightAnchor),
            collectionView.centerXAnchor.constraint(equalTo: collectionContainer.centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: collectionContainer.centerYAnchor),
            ])
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: buttons[indexPath.row].frame.width + 25 , height: buttons[indexPath.row].frame.height)
    }
    
    @objc func test() {
//        DeezerManager.sharedInstance.login()
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance()?.signIn()
//        FacebookManager.linkWithFacebook(in: self) { (str, err, profile) in
//            print("hey")
//        }
    }
  

    
    func sessionDidLogin(result: ResultLogin) {
        switch result {
        case .success:
            DeezerManager.sharedInstance.getMe { (user, err) in
                print(user)
            }
        case .logout:
            break
        case .error(let error):
            print("error")
        }
    }
    
}
