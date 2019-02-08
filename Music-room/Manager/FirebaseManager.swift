//
//  FirebaseManager.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/5/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

struct FirebaseManager {
    
    static var firestoreDatabase: Firestore = {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db
    }()
    
    static func createUser(user: User, cb: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let url = URL(string: "https://us-central1-music-room-42.cloudfunctions.net/createUser")!
        var request = URLRequest(url: url)
        let encodedData = try? JSONEncoder().encode(user)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encodedData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            cb(data, response, error)
        }
        task.resume()
    }
    
    static func getPublicPlaylists(cb: @escaping ([Playlist]) -> Void) {
        let url = URL(string: "https://us-central1-music-room-42.cloudfunctions.net/getAllPlaylist")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        Auth.auth().currentUser?.getIDToken(completion: { (tokenCb, err) in
            if err != nil {
                print(err)
                return
            } else {
                let tokenBearer = "Bearer \(tokenCb!)"
                print(tokenBearer)
                request.setValue(tokenBearer , forHTTPHeaderField: "Authorization")
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
                    if err != nil {
                        print(err!.localizedDescription)
                        return
                    }
                    do {
                        let playlist = try JSONDecoder().decode([Playlist].self, from: data!)
                        cb(playlist)
                    } catch {
                        print(error)
                    }
                }
                task.resume()
            }
        })
    }
}

extension FirebaseManager {
    static let Firestore_Users_Collection = FirebaseManager.firestoreDatabase.collection(SparkKeys.CollectionPath.users)
    static let Storage_Profile_Images = Storage.storage().reference().child(SparkKeys.StorageFolder.profileImages)
}
