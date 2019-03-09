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
    
    struct PlaylistUrl {
        static let event = "https://us-central1-music-room-42.cloudfunctions.net/getAllEvent"
        static let allPlaylist = "https://us-central1-music-room-42.cloudfunctions.net/getAllPlaylist"
        static let addPlaylist = "https://us-central1-music-room-42.cloudfunctions.net/createPlaylist"
        static let addEvent = "https://us-central1-music-room-42.cloudfunctions.net/createEvent"
    }
    
    static var firestoreDatabase: Firestore = {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        return db
    }()
    
//    static var playListRequest: URLRequest = {
//
//    }()
    
    
    fileprivate static func requestCompletion(data: Data?, response: URLResponse?, err: Error?) -> [String: Any]? {
        if err != nil {
            print(err!.localizedDescription)
            return nil
        }
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("\(httpResponse.statusCode)")
            return nil
        }
        do {
            let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
            return result
        } catch {
            print(error)
            return nil
        }
    }

    static func getRequestWithToken(url: String, queryItem: [URLQueryItem]?, result: @escaping ([String: Any]?) -> ()) {
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = queryItem
        let url = urlComponents?.url!
        guard let urlRequest = url else {
            print("wrong url")
            return
        }
        var request = URLRequest(url: urlRequest)
        getToken { (token) in
            guard let token = token else { return }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
                let res = self.requestCompletion(data: data, response: response, err: err)
                result(res)
            }
            task.resume()
        }
        return
    }
    
    static func getToken(completion: @escaping (String?) -> ()) {
        guard let user = Auth.auth().currentUser else {  completion(nil);  return }
        user.getIDToken { (token, err) in
            if err != nil {
                print(err!)
                completion(nil)
                return
            }
            completion(token)
        }
    }
    
    
    static func postRequestWithToken(url: String, queryItem: [URLQueryItem]?, data: Data?, result: @escaping (Int) -> ()) {
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = queryItem
        let url = urlComponents?.url!
        guard let urlRequest = url else {
            print("wrong url")
            return
        }
        
        var request = URLRequest(url: urlRequest)
        getToken { (token) in
            guard let token = token else { return }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = data
            let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
                if err != nil {
                    print(err!)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else { return }
                let x = jsonHelper.convertJSONToObject(data: data)
                if let _ = x {
                    print(x!["message"])
                }
                result(httpResponse.statusCode)
            }
            task.resume()
        }
    
    }

    
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
