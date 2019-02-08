import Firebase
import FirebaseAuth
import JGProgressHUD
import SwiftyJSON
import FirebaseStorage
import FacebookCore
import FacebookLogin

class FacebookManager {
    
    // MARK: -
    // MARK: Logout
    static func logout(completion: @escaping (_ result: Bool, _ error: Error?) ->()) {
        do {
            try Auth.auth().signOut()
            print("Successfully signed out")
            completion(true, nil)
        } catch let err {
            print("Failed to sign out with error:", err)
            completion(false, err)
        }
    }
    
    // MARK: -
    // MARK: Sign in with Facebook
    static func signInWithFacebook(in viewController: UIViewController, completion: @escaping (_ message: String, _ error: Error?, _ facebookReturn: FacebookProfile?) ->()) {
        let loginManager = LoginManager()

        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: viewController) { (result) in
            switch result {
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                print("Succesfully logged in into Facebook.")
                self.signIntoFirebaseWithFacebook(completion: completion)
            case .failed(let err):
                completion("Failed to get Facebook user with error:", err, nil)
            case .cancelled:
                completion("Canceled getting Facebook user.", nil, nil)
            }
        }
    }
    
    // MARK: -
    // MARK: Fileprivate functions
    fileprivate static func signIntoFirebaseWithFacebook(completion: @escaping (_ message: String, _ error: Error?, _ facebookReturn: FacebookProfile?) ->()) {
        guard let authenticationToken = AccessToken.current?.authenticationToken else {
            completion("Could not fetch authenticationToken", nil, nil)
            return
        }
        let facebookCredential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)
        signIntoFirebase(withFacebookCredential: facebookCredential, completion: completion)
    }
    
    fileprivate static func signIntoFirebase(withFacebookCredential facebookCredential: AuthCredential, completion: @escaping (_ message: String, _ error: Error?, _ facebookReturn: FacebookProfile?) ->()) {
        Auth.auth().signInAndRetrieveData(with: facebookCredential) { (result, err) in
            if let err = err { completion("Failed to sign up with error:", err, nil); return }
            print("Succesfully authenticated with Firebase.")
            self.fetchFacebookUser(completion: completion)
        }
    }
    
    fileprivate static func fetchFacebookUser(completion: @escaping (_ message: String, _ error: Error?, _ facebookReturn: FacebookProfile?) ->()) {
        
        let graphRequestConnection = GraphRequestConnection()
        let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, picture.type(large)"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: .defaultVersion)
        graphRequestConnection.add(graphRequest, completion: { (httpResponse, result) in
            switch result {
            case .success(response: let response):
                var facebookProfile: FacebookProfile?
                guard let firebaseUID = Auth.auth().currentUser?.uid else { completion("Failed to fetch profilePictureUrl.", nil, nil); return }
                guard let responseDict = response.dictionaryValue else { completion("Failed to fetch user.", nil, nil); return }
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: .prettyPrinted)
                    facebookProfile = try JSONDecoder().decode(FacebookProfile.self, from: jsonData )
                } catch {
                    print(error)
                    completion("Failed to fetch UserProfileData json.", nil, nil)
                    return
                }
    
                guard let url = URL(string: (facebookProfile?.picture.data.url)!) else { completion("Failed to create profile picture url.", nil, nil); return }

                URLSession.shared.dataTask(with: url) { (data, response, err) in
                    if err != nil { completion("Failed to fetch profile picture with err:", err, nil); return }
                    guard let data = data else { completion("Failed to fetch profile picture data with err:", nil, nil); return }
                    saveUserIntoFirebaseDatabase(profileImageData: data, facebookUser: facebookProfile, firebaseUID: firebaseUID, completion: completion)

                    }.resume()
                
                break
            case .failed(let err):
                completion("Failed to get Facebook user with error:", err, nil)
                break
            }
        })
        graphRequestConnection.start()
        
    }
    
    fileprivate static func saveUserIntoFirebaseDatabase(profileImageData: Data, facebookUser: FacebookProfile?, firebaseUID: String, completion: @escaping (_ message: String, _ error: Error?, _ facebookReturn: FacebookProfile?) ->()) {
        guard let facebookUser = facebookUser else { completion("Failed to fetch FacebookkUser", nil, nil); return }
        fetchFacebookkUser(firebaseUID) { (message, err, fetchedFacebookUser) in
            if let err = err {
                completion("Failed to fetch user data", err, nil)
                return
            }
            
            guard let fetchedFacebookUser = fetchedFacebookUser else {
                saveFacebookUser(profileImageData: profileImageData, facebookUser: facebookUser, firebaseUID: firebaseUID, completion: completion)
                return
            }
            deleteAsset(fromUrl: fetchedFacebookUser.picture.data.url, completion: { (result, err) in
                if let err = err {
                    completion("Failed to deleted profile image form Storage", err, nil)
                    return
                }
                if result {
                    saveFacebookUser(profileImageData: profileImageData, facebookUser: facebookUser, firebaseUID: firebaseUID, completion: completion)
                    
                } else {
                    completion("Failed to delete profile image from Storage", err, nil)
                }
            })
        }
    }
    
    fileprivate static func saveFacebookUser(profileImageData: Data, facebookUser: FacebookProfile, firebaseUID: String, completion: @escaping (_ message: String, _ error: Error?, _ facebookReturn: FacebookProfile?) ->()) {
        
        guard let profileImage = UIImage(data: profileImageData) else { completion("Failed to generate profile image from data", nil, nil); return }
        guard let profileImageUploadData = profileImage.jpegData(compressionQuality: 0.3) else { completion("Failed to compress jpeg data", nil, nil); return }
        
        let fileName = UUID().uuidString
        FirebaseManager.Storage_Profile_Images.child(fileName).putData(profileImageUploadData, metadata: nil) { (metadata, err) in
           
            if let err = err { completion("Failed to save profile image to Storage with error:", err, nil); return }
            guard let metadata = metadata, let path = metadata.path else { completion("Failed to get metadata or path to profile image url.", nil, nil); return }
           
            FacebookManager.getDownloadUrl(from: path, completion: { (profileImageFirebaseUrl, err) in
                if let err = err { completion("Failed to get download url with error:", err, nil); return }
                guard let profileImageFirebaseUrl = profileImageFirebaseUrl else { completion("Failed to get profileImageUrl.", nil, nil); return }
                print("Successfully uploaded profile image into Firebase storage with URL:", profileImageFirebaseUrl)
              
                let facebookDocument = FacebookProfile(email: facebookUser.email, name: facebookUser.name, id: firebaseUID, picture: DataFacebookPicture(data: facebookUser.picture.data.changeValues(url: profileImageFirebaseUrl)))
                let facebookProfileContainer = FacebookProfileContainer(facebookProfile: facebookDocument)
                print(facebookDocument.id)
                FirebaseManager.Firestore_Users_Collection.document(facebookDocument.id).setData(facebookProfileContainer.dictionary, completion: { (err) in
                    if let err = err { completion("Failed to save document with error:", err, nil); return }
                    print("Successfully saved user info into Firestore: \(String(describing: facebookDocument))")
                    completion("Successfully signed in with Facebook.", nil, facebookDocument)
                })
            })
        }
    }
    
    // MARK: -
    // MARK: Fetch Profile Image
    static func fetchProfileImage(facebookUser: FacebookProfile, completion: @escaping (_ message: String, _ error: Error?, _ image: UIImage?) ->()) {
        let profileImageUrl = facebookUser.picture.data.url
        guard let url = URL(string: profileImageUrl) else { completion("Failed to create url for profile image.", nil, nil); return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if err != nil { completion("Failed to fetch profile image with url:", err, nil); return }
            guard let data = data else { completion("Failed to fetch profile image data", nil, nil); return }
            let profileImage = UIImage(data: data)
            completion("Successfully fetched profile image", nil, profileImage)
            }.resume()
    }
    
    // MARK: -
    // MARK: Fetch Current Facebook User
    static func fetchCurrentFacebookUser(completion: @escaping (_ message: String, _ error: Error?, _ facebookReturn: FacebookProfile?) ->()) {
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else { completion("Failed to fetch user uid.", nil, nil); return }
            fetchFacebookkUser(uid, completion: completion)
        }
    }
    
    // MARK: -
    // MARK: Fetch Facebook User with uid
    static func fetchFacebookkUser(_ uid: String, completion: @escaping (_ message: String, _ error: Error?, _ facebookReturn: FacebookProfile?) ->()) {
        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { (snapshot, err) in
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: snapshot?.data(), options: .prettyPrinted)
                let facebookProfileContainer = try JSONDecoder().decode(FacebookProfileContainer.self, from: jsonData)
                completion("Successfully fetched facebook user", nil, facebookProfileContainer.facebookProfile)
            } catch {
                completion("Failed to get facebook user from snapshot.", nil, nil)
            }
        }
    }
    
    // MARK: -
    // MARK: Delete Asset
    static func deleteAsset(fromUrl url: String, completion: @escaping (_ result: Bool, _ error: Error?) ->()) {
        Storage.storage().reference(forURL: url).getMetadata { (metadata, err) in
            if let err = err, let errorCode = StorageErrorCode(rawValue: err._code) {
                if errorCode == .objectNotFound {
                    print("Asset not found, no need to delete")
                    completion(true, nil)
                    return
                }
            }
            Storage.storage().reference(forURL: url).delete { (err) in
                if let err = err {
                    print("Could not delete asset at url:", url)
                    completion(false, err)
                    return
                }
                print("Successfully deleted asset from url:", url)
                completion(true, nil)
            }
        }
    }
    
    // MARK: -
    // MARK: Get download URL
    static func getDownloadUrl(from path: String, completion: @escaping (String?, Error?) -> Void) {
        Storage.storage().reference().child(path).downloadURL { (url, err) in
            completion(url?.absoluteString, err)
        }
    }
    
    
    static func linkWithFacebook(in viewController: UIViewController, completion: @escaping (_ message: String, _ error: Error?, _ facebookReturn: FacebookProfile?) ->()) {
        let loginManager = LoginManager()
       
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: viewController) { (result) in
            switch result {
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                print("Succesfully logged in into Facebook.")
                guard let authenticationToken = AccessToken.current?.authenticationToken else {
                    completion("Could not fetch authenticationToken", nil, nil)
                    return
                }
                let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)
                Auth.auth().currentUser?.linkAndRetrieveData(with: credential, completion: { (data, err) in
                    print("err ---->", err)
                    print("data ----->", data)
                })
            case .failed(let err):
                completion("Failed to get Facebook user with error:", err, nil)
            case .cancelled:
                completion("Canceled getting Facebook user.", nil, nil)
            }
        }
        
    }
    
    static func unlinkFacebookAccount() {
        Auth.auth().currentUser?.unlink(fromProvider: "facebook.com", completion: { (result, err) in
            print(result)
            print(err)
        })
    }
    
    
}
