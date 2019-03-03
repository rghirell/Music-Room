
//
//  UserAccountViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/15/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import GoogleSignIn



class UserAccountViewController: UIViewController , CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GIDSignInDelegate {
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttons.count
    }
    
    let titles = ["Jazz", "Electro", "Rap", "Pop", "Hip-hop", "Rock", "Chill", "Ambiance", "Latino", "Affro", "RnB", "Classique"]
    var buttons = [UIButton]()
    var isLinkedToGoogle = false {
        didSet {
            DispatchQueue.main.async {
                if self.isLinkedToGoogle {
                    self.buttonTest.setTitle("unlink", for: .normal)
                } else { self.buttonTest.setTitle("link", for:  .normal) }
            }
        }
    }
    
    var isLinkedToFacebook = false {
        didSet {
            DispatchQueue.main.async {
                if self.isLinkedToFacebook {
                    self.facebookLinkButton.setTitle("Unlink account", for: .normal)
                } else { self.facebookLinkButton.setTitle("Link account", for:  .normal) }
            }
        }
    }
    
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
    
    let facebookLinkButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        let fbLogo = UIImage(named: "fbWhiteLogo")
        button.setTitle("Link account", for: .normal)
        button.setImage(fbLogo, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: -20 , bottom: 5, right: 0)
        button.layer.masksToBounds = true
        button.tintColor = #colorLiteral(red: 0.9688121676, green: 0.9688346982, blue: 0.9688225389, alpha: 1)
        button.backgroundColor = #colorLiteral(red: 0.2745098039, green: 0.368627451, blue: 0.662745098, alpha: 1)
        return button
    }()
    
    let collectionContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    
    var ref: DocumentReference!

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        unlinkGoogleAccount()
        setupLinkButtons()
        setupLayout()
        DeezerManager.sharedInstance.loginResult = sessionDidLogin
        guard let user = Auth.auth().currentUser else { return }
        self.ref = Firestore.firestore().collection("users").document(user.uid)
        ref.getDocument { (document, error) in
            if let document = document, document.exists {
                self.isLinkedToGoogle =  document.data()!["is_linked_to_google"] as! Bool
                self.isLinkedToFacebook = document.data()!["is_linked_to_facebook"] as! Bool
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func setupLinkButtons() {
        view.addSubview(buttonTest)
        buttonTest.addTarget(self, action: #selector(test), for: .touchUpInside)
    
        view.addSubview(facebookLinkButton)
        facebookLinkButton.addTarget(self, action: #selector(facebookLinkAction), for: .touchUpInside)
    }
    
    @objc private func facebookLinkAction() {
        if isLinkedToFacebook {
            FacebookManager.unlinkFacebookAccount()
            isLinkedToFacebook = false
        } else {
            FacebookManager.linkWithFacebook(in: self) { (_, _, _) in self.isLinkedToFacebook = true }
        }
    }
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        for title in titles {
            buttons.append(createButton(withTitle: title))
        }
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 30, bottom: 10, right: 30)
        layout.minimumInteritemSpacing = 8
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = true
        collectionContainer.clipsToBounds = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TagsCollectionViewCell.self, forCellWithReuseIdentifier: "test")
        collectionContainer.addSubview(collectionView)
        view.addSubview(collectionContainer)
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
            facebookLinkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            facebookLinkButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            facebookLinkButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24),
            facebookLinkButton.heightAnchor.constraint(equalToConstant: 30),
            ])
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: buttons[indexPath.row].frame.width + 25 , height: buttons[indexPath.row].frame.height)
    }
    
    @objc func test() {
//        DeezerManager.sharedInstance.login()
          GIDSignIn.sharedInstance().delegate = self
        if isLinkedToGoogle {
            unlinkGoogleAccount()
        } else {
                    GIDSignIn.sharedInstance()?.signOut()
                    GIDSignIn.sharedInstance()?.signIn()
        }

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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().currentUser?.linkAndRetrieveData(with: credential, completion: { (data, err) in
            if err != nil {
                print(err!)
                return
            }
            guard let user = self.ref else { return }
            user.setData(["is_linked_to_google": true], merge: true)
            self.isLinkedToGoogle = true
//            ref.removeAllObservers()
        })
    }
    
    func unlinkGoogleAccount() {
        Auth.auth().currentUser?.unlink(fromProvider: "google.com", completion: { (result, err) in
            print(result)
            print(err)
            guard let user = self.ref else { return }
            user.updateData(["is_link_to_google": false])
            self.isLinkedToGoogle = false
        })
    }
    
    
}
