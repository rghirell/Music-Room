
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
 
    let titles = ["Jazz", "Electro", "Rap", "Pop", "Hip-hop", "Rock", "Chill", "Ambiance", "Latino", "Affro", "RnB", "Classique"]
    var buttons = [UIButton]()
    var preferences = [String]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var preferencesListener: ListenerRegistration!
    var isLinkedToGoogle = false {
        didSet {
            DispatchQueue.main.async {
                if self.isLinkedToGoogle {
                    self.googleLinkButton.setTitle("Unlink Google account", for: .normal)
                } else { self.googleLinkButton.setTitle("Link Google account", for:  .normal) }
            }
        }
    }
    
    var isLinkedToFacebook = false {
        didSet {
            DispatchQueue.main.async {
                if self.isLinkedToFacebook {
                    self.facebookLinkButton.setTitle("Unlink Facebook account", for: .normal)
                } else { self.facebookLinkButton.setTitle("Link Facebook account", for:  .normal) }
            }
        }
    }
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var collectionView: UICollectionView!
    
    let googleLinkButton: UIButton = {
        let button = UIButton()
         button.titleLabel!.font = UIFont(name: "Futura-bold", size: 16)!
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 3, height: 3)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 4.0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Link Google account", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        let googleLogo = UIImage(named: "btn_google_light_normal_ios")
        button.tintColor = .clear
        button.setImage(googleLogo, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: -30 , bottom: 2, right: 0)
        return button
    }()
    
    let facebookLinkButton: UIButton = {
        let button = UIButton()
         button.titleLabel!.font = UIFont(name: "Futura-bold", size: 16)!
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 3, height: 3)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 4.0
        button.translatesAutoresizingMaskIntoConstraints = false
        let fbLogo = UIImage(named: "fbWhiteLogo")
        button.setTitle("Link account", for: .normal)
        button.setImage(fbLogo, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: -20 , bottom: 5, right: 0)
        button.tintColor = #colorLiteral(red: 0.9688121676, green: 0.9688346982, blue: 0.9688225389, alpha: 1)
        button.backgroundColor = #colorLiteral(red: 0.2745098039, green: 0.368627451, blue: 0.662745098, alpha: 1)
        return button
    }()
    
    let logOutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .red
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 3, height: 3)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 4.0
        button.tintColor = .white
        button.titleLabel!.font = UIFont(name: "Futura-bold", size: 16)!
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Logout", for: .normal)
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return button
    }()
    
    let collectionContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    
    var ref: DocumentReference!
    var providerID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        providerID = Auth.auth().currentUser?.providerData[0].providerID
        setupLinkButtons()
        setupLayout()
        DeezerManager.sharedInstance.loginResult = sessionDidLogin
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "back_24"), for: .normal)
        button.setTitle("Playlist", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem?.tintColor = .black
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let ref =  Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        preferencesListener = ref.addSnapshotListener { (doc, err) in
            guard let doc = doc else { return }
            guard let data = doc.data() else { return }
            guard let preferences =  data["pref_music"] else { return }
            DispatchQueue.main.async {
                self.preferences = preferences as! [String]
            }
        }
    }
    
    @objc func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        preferencesListener.remove()
    }
    
    func createButton(withTitle title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 15
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 5,left: 5,bottom: 5,right: 5)
        button.isUserInteractionEnabled = false
        button.sizeToFit()
        return button
    }
    
    //MARK: -
    //MARK: Layout setup
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
        collectionView.backgroundColor = .white
        collectionContainer.clipsToBounds = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TagsCollectionViewCell.self, forCellWithReuseIdentifier: "test")
        collectionContainer.addSubview(collectionView)
        view.addSubview(collectionContainer)
        NSLayoutConstraint.activate([
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
            googleLinkButton.widthAnchor.constraint(equalTo: facebookLinkButton.widthAnchor),
            googleLinkButton.heightAnchor.constraint(equalTo: facebookLinkButton.heightAnchor),
            googleLinkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleLinkButton.bottomAnchor.constraint(equalTo: facebookLinkButton.topAnchor, constant: -12),
            logOutButton.widthAnchor.constraint(equalTo: facebookLinkButton.widthAnchor),
            logOutButton.heightAnchor.constraint(equalTo: facebookLinkButton.heightAnchor),
            logOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logOutButton.bottomAnchor.constraint(equalTo: googleLinkButton.topAnchor, constant: -12),
            ])
    }
    
    private func setupLinkButtons() {
        view.addSubview(googleLinkButton)
        googleLinkButton.addTarget(self, action: #selector(googleLinkAction), for: .touchUpInside)
        view.addSubview(facebookLinkButton)
        facebookLinkButton.addTarget(self, action: #selector(facebookLinkAction), for: .touchUpInside)
        view.addSubview(logOutButton)
        switch providerID {
        case "google.com":
            googleLinkButton.isEnabled = false
            googleLinkButton.backgroundColor = #colorLiteral(red: 0.6820679903, green: 0.6820679903, blue: 0.6820679903, alpha: 1)
        case "facebook.com":
            facebookLinkButton.isEnabled = false
        default:
            return
        }
    }
    
    //MARK: -
    //MARK: CollectionView Logic
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: buttons[indexPath.row].frame.width + 25 , height: buttons[indexPath.row].frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "test", for: indexPath) as! TagsCollectionViewCell
        cell.button.setTitle(titles[indexPath.row], for: .normal)
        if (preferences.contains(titles[indexPath.row])) {
            cell.label.text = "✓"
        } else { cell.label.text = "+" }
        
        cell.backgroundColor = .red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        addOrRemoveTag(tag: titles[indexPath.row])
    }
    
    func addOrRemoveTag(tag: String) {
        let ref = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        let add = preferences.contains(tag)
        if !add {
            ref.updateData(["pref_music": FieldValue.arrayUnion([tag])])
        } else {
            ref.updateData(["pref_music": FieldValue.arrayRemove([tag])])
        }
    }
}


extension UserAccountViewController {
    //MARK: -
    //MARK: Link Management
    @objc private func facebookLinkAction() {
        if isLinkedToFacebook {
            FacebookManager.unlinkFacebookAccount()
            isLinkedToFacebook = false
        } else {
            if providerID == "password" {
                verifyPassword { (str) in
                    FacebookManager.linkWithFacebook(in: self) { (msg, err, _) in
                        if err != nil {
                            let alert = Alert.errorAlert(title: "Error linking account", message: err?.localizedDescription)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                            return
                        }
                        if msg != "cancel" {
                            self.isLinkedToFacebook = true
                        }
                    }
                }
            }
        }
    }
    
    @objc func googleLinkAction() {
        //                DeezerManager.sharedInstance.login()
        GIDSignIn.sharedInstance().delegate = self
        if isLinkedToGoogle {
            unlinkGoogleAccount()
        } else {
            if providerID == "password" {
                verifyPassword { (str) in
                    GIDSignIn.sharedInstance()?.signOut()
                    GIDSignIn.sharedInstance()?.signIn()
                }
            } else {
                GIDSignIn.sharedInstance()?.signOut()
                GIDSignIn.sharedInstance()?.signIn()
            }
        }
    }
    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        return textField
    }
    
    @objc private func signOut() {
        switch providerID! {
        case "google.com":
            GIDSignIn.sharedInstance()?.signOut()
        default:
            print("hello")
        }
        do {
            try Auth.auth().signOut()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        } catch  {
            let alert = Alert.errorAlert(title: "Error", message: "Couldn't log out")
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func verifyPassword(completion: @escaping (String) -> ()) {
        let tf = createTextField(placeholder: "Password")
        var alert = UIAlertController()
        alert = Alert.alert(style: .alert, title: "Password verification", message: "Please verify your password", textFields: [tf]) { password in
            Auth.auth().signIn(withEmail: Auth.auth().currentUser!.email!, password: password![0], completion: { (res, err) in
                if err != nil {
                    let alert = Alert.errorAlert(title: "Wrong password", message: err!.localizedDescription)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                completion("success")
            })
        }
        present(alert, animated: true, completion: nil)
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
                let alert = Alert.errorAlert(title: "Error linking account", message: err!.localizedDescription)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            guard let user = self.ref else { return }
            user.setData(["is_linked_to_google": true], merge: true)
            self.isLinkedToGoogle = true
        })
    }
    
    private func unlinkGoogleAccount() {
        Auth.auth().currentUser?.unlink(fromProvider: "google.com", completion: { (result, err) in
            if err != nil {
                let alert = Alert.errorAlert(title: "Error unlinking account", message: err!.localizedDescription)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            guard let user = self.ref else { return }
            user.updateData(["is_linked_to_google": false])
            self.isLinkedToGoogle = false
        })
    }

}
