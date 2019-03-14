
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
                let view = self.googleLinkView.viewWithTag(1) as! UILabel
                if self.isLinkedToGoogle {
                    view.text = "Unlink Google account"
                } else { view.text =  "Link Google account" }
            }
        }
    }
    
    var isLinkedToFacebook = false {
        didSet {
            DispatchQueue.main.async {
                let view = self.facebookLinkView.viewWithTag(1) as! UILabel
                if self.isLinkedToFacebook {
                    view.text = "Unlink Facebook account"
                } else { view.text = "Link Facebook account" }
            }
        }
    }
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var googleLinkView: UIView!
    @IBOutlet weak var facebookLinkView: UIView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deezerLink: UIButton!
    
    
    var ref: DocumentReference!
    var providerID: String!
    
    //MARK: -
    //MARK: - View cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLinkButtons()
        setupLayout()
        DeezerManager.sharedInstance.loginResult = sessionDidLogin
        guard let user = Auth.auth().currentUser else { return }
        self.ref = Firestore.firestore().collection("users").document(user.uid)
        ref.getDocument { (document, error) in
            if let document = document, document.exists {
                if let linkGoogle = document.data()!["is_linked_to_google"] {
                    self.isLinkedToGoogle = linkGoogle as! Bool
                } else { self.isLinkedToGoogle = false }
                if let linkFacebook = document.data()!["is_linked_to_facebook"] {
                     self.isLinkedToFacebook = linkFacebook as! Bool
                } else { self.isLinkedToFacebook = false }
               
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBOutlet weak var displayName: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let ref =  Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        preferencesListener = ref.addSnapshotListener { (doc, err) in
            guard let doc = doc else { return }
            guard let data = doc.data() else { return }
            guard let accessibility = data["accessibility"] as? [String: Bool] else { return }
            guard let preferences =  data["pref_music"] else { return }
            guard let displayName = data["displayName"] as? String else { return }
            self.displayName.text = displayName
          
            DispatchQueue.main.async {
                if accessibility["public"] != nil && accessibility["public"]! == true {
                    self.visibility.isOn = false
                }
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

    
    //MARK: -
    //MARK: - Layout setup
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        for title in titles {
            buttons.append(createButton(withTitle: title))
        }
        
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "back_24"), for: .normal)
        button.setTitle("Playlist", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem?.tintColor = .black
        setCornerLayer(viewArray: [logOutButton, deezerLink, googleLinkView, facebookLinkView])
        logOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        let tapGoogle = UITapGestureRecognizer(target: self, action: #selector(googleLinkAction))
        googleLinkView.addGestureRecognizer(tapGoogle)
        let tapFacebook = UITapGestureRecognizer(target: self, action: #selector(facebookLinkAction))
        facebookLinkView.addGestureRecognizer(tapFacebook)
        deezerLink.addTarget(self, action: #selector(deezerLinkAction), for: .touchUpInside)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 30, bottom: 10, right: 30)
        layout.minimumInteritemSpacing = 8
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = .white
        collectionView.register(TagsCollectionViewCell.self, forCellWithReuseIdentifier: "test")

    }
    
    private func setCornerLayer(viewArray: [UIView]) {
        for element in viewArray {
            element.layer.cornerRadius = 5
            element.layer.borderColor = UIColor.black.cgColor
            element.layer.shadowColor = UIColor.black.cgColor
            element.layer.shadowOffset = CGSize(width: 3, height: 3)
            element.layer.shadowOpacity = 0.4
            element.layer.shadowRadius = 4.0
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
        button.isUserInteractionEnabled = false
        button.sizeToFit()
        return button
    }
    
    private func setupLinkButtons() {
        switch providerID {
        case "google.com":
            googleLinkView.isUserInteractionEnabled = false
            googleLinkView.backgroundColor = #colorLiteral(red: 0.6820679903, green: 0.6820679903, blue: 0.6820679903, alpha: 1)
        case "facebook.com":
            facebookLinkView.isUserInteractionEnabled = false
            facebookLinkView.backgroundColor = #colorLiteral(red: 0.6820679903, green: 0.6820679903, blue: 0.6820679903, alpha: 1)
        default:
            return
        }
    }
    
    
    @IBOutlet weak var visibility: UISwitch!
    @IBAction func changeVisibility(_ sender: Any) {
        if visibility.isOn {
            ref.updateData(["accessibility.public": false])
        } else { ref.updateData(["accessibility.public": true])}
    }
    
    //MARK: -
    //MARK: - CollectionView Logic
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
    
    @objc func deezerLinkAction() {
        DeezerManager.sharedInstance.login()
        ref.updateData(["is_linked_to_deezer": true])
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
                // todo
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
