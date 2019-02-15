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

 let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6Ijk3ZmNiY2EzNjhmZTc3ODA4ODMwYzgxMDAxMjFlYzdiZGUyMmNmMGUiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbXVzaWMtcm9vbS00MiIsIm5hbWUiOiJsb2xvbG9sb2wiLCJhdWQiOiJtdXNpYy1yb29tLTQyIiwiYXV0aF90aW1lIjoxNTUwMjUzNDY2LCJ1c2VyX2lkIjoiYnRoaWtRbmZ6VGVHSFZPbmh3WEtDck5LWkt5MSIsInN1YiI6ImJ0aGlrUW5melRlR0hWT25od1hLQ3JOS1pLeTEiLCJpYXQiOjE1NTAyNTM0NjgsImV4cCI6MTU1MDI1NzA2OCwiZW1haWwiOiJyZ2hpcmVsbEBzdHVkZW50LjQyLmZyIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnsiZW1haWwiOlsicmdoaXJlbGxAc3R1ZGVudC40Mi5mciJdfSwic2lnbl9pbl9wcm92aWRlciI6InBhc3N3b3JkIn19.ZkdlvzOoi80gn9490-iJCSNTPT-VxqsJUQKDMzgXiJRFUuh2XICVZXA1ZmVrDi1tU7_PIurjQTtDbJIf4G5OSOUQY2ciRt2SPiW31HjaYG0JOhs5cNu_JKrzU0t1UKF9sqr7HKFzXhUZdhGx-7OI8l9sVamG1_LYDCRlonN40gE2lcmjIlrBGUdifyUmeuZgCb6M4nc80e2c9Q5qKZ7sgRmRI_fpTz1iIJM5Mf8eD0UuLW4sVL9L_BZAr1osDY_mya2i00F8RFV9XxHBGCrP6wZAX1DGnbdRIRlPZ0b8olxTrNMq-xhMWFjeeWjFL72_KxA16TdCxD_E6MDxFCGyEw"
struct FirebaseManager {
    
   
    
    struct PlaylistUrl {
        static let event = "https://us-central1-music-room-42.cloudfunctions.net/getAllEvent"
        static let allPlaylist = "https://us-central1-music-room-42.cloudfunctions.net/getAllPlaylist"
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
    
    fileprivate static func requestCompletion<T: Decodable>(data: Data?, response: URLResponse?, err: Error?) -> [T]? {
        if err != nil {
            print(err!.localizedDescription)
            return nil
        }
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("\(httpResponse.statusCode)")
            let result = jsonHelper.convertJSONToObject(data: data)
            if let _ = result {
                print(result!["message"])
            }
//            return nil
        }
        do {
            let result = try JSONDecoder().decode([T].self, from: data!)
            return result
        } catch {
            print(error)
            return nil
        }
    }
    
    
    static func getRequestWithToken<T: Decodable>(url: String, queryItem: [URLQueryItem]?, result: @escaping ([T]?) -> Void) -> [T]?  {
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = queryItem
        let url = urlComponents?.url!
        guard let urlRequest = url else {
            print("wrong url")
            return nil
        }
        var request = URLRequest(url: urlRequest)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
            let res: [T]? = self.requestCompletion(data: data, response: response, err: err)
            result(res)
        }
        task.resume()
        return nil
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
