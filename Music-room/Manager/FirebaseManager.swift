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

 let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjNiYmQyOGVkYzNkMTBiOTI5ZjU3NWEyY2E2ODU0OWZjYTZkODg5OTMiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vbXVzaWMtcm9vbS00MiIsIm5hbWUiOiJyZ2hpcmVsbCIsImF1ZCI6Im11c2ljLXJvb20tNDIiLCJhdXRoX3RpbWUiOjE1NTA4NTM0NjcsInVzZXJfaWQiOiJBREtvMHZNcGEyTWxudE9nNlBHd1Y2Nm1rMU8yIiwic3ViIjoiQURLbzB2TXBhMk1sbnRPZzZQR3dWNjZtazFPMiIsImlhdCI6MTU1MDg1MzQ2OCwiZXhwIjoxNTUwODU3MDY4LCJlbWFpbCI6InJnaGlyZWxsQHN0dWRlbnQuNDIuZnIiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJlbWFpbCI6WyJyZ2hpcmVsbEBzdHVkZW50LjQyLmZyIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifX0.SUaLXCB9i4sG2cXNxAWLzWTr0P9Cp9bXbgcKaTyhqXhSBaQmjqfVGUnPirXbhq8PY8QSV78tqi6u8kDivESsWREI5D1M_Wxl0X-IT4ZliBnh-sGbvK-XTJ0M2S7nkJm0gZ5E1FTkK1FISh6JQ_-fFX_WLaSo_qfvYuT-vaTyKSVpqli_4ua_zwPiW1esd37pshFlsW6_tx5ribjuGoBMeI43loK0VWPbxCfjfAZgvzAgZiU_8ASuF9LFt8HTonwq-RGXnSySzq1f3xh_PrDbbBotWbIIg8eY0sLoCrcGZ_gLG80ofeup8EQvgtlwyBVW756IFNf5lpK-lRpXSmkTLQ"

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
    
    @discardableResult
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
    
    
    static func postRequestWithToken(url: String, queryItem: [URLQueryItem]?, data: Data?, result: @escaping (Int) -> ()) {
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = queryItem
        let url = urlComponents?.url!
        guard let urlRequest = url else {
            print("wrong url")
            return
        }
        var request = URLRequest(url: urlRequest)
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
