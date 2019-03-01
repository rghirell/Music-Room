//
//  DeezerManager.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/25/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import Foundation


import UIKit

enum ResultLogin {
    case success
    case logout
    case error(error: Error?)
}

enum SessionState {
    case connected
    case disconnected
}

typealias LoginResult = ((_ result: ResultLogin) -> ())

// MARK: - DeezerManager manages the request to DeezerSDK

class DeezerManager: NSObject {
    
    // Needed to handle every types of request from DeezerSDK
    var deezerConnect: DeezerConnect?
    
    // .diconnected / .connected
    var sessionState: SessionState {
        if let connect = deezerConnect {
            return connect.isSessionValid() ? .connected : .disconnected
        }
        return .disconnected
    }
    
    // Set a function or callback to this property if you want to get the result after login
    var loginResult: LoginResult?
    
    static let sharedInstance : DeezerManager = {
        let instance = DeezerManager()
        instance.startDeezer()
        return instance
    }()
    
    func startDeezer() {
        deezerConnect = DeezerConnect.init(appId: DeezerConstant.AppKey.appId, andDelegate: self)
        DZRRequestManager.default().dzrConnect = deezerConnect
    }
    
    
    /**
     *   Authorizations:
     *      - DeezerConnectPermissionBasicAccess
     *      - DeezerConnectPermissionEmail
     *      - DeezerConnectPermissionOfflineAccess
     *      - DeezerConnectPermissionManageLibrary
     *      - DeezerConnectPermissionDeleteLibrary
     *      - DeezerConnectPermissionListeningHistory
     **/
    
    func login() {
        deezerConnect?.authorize([DeezerConnectPermissionBasicAccess])
    }
    
    func logout() {
        deezerConnect?.logout()
    }
}

// MARK: - Token Handler inside the Keychain because it's sensitive data
typealias DeezerObjectListRequest = (_ objectList: DZRObjectList? ,_ error: Error?) -> Void

struct DeezerConstant {
    
    // Key saved in Keychain
    struct KeyChain {
        static let deezerTokenKey = "DeezerTokenKey"
        static let deezerExpirationDateKey = "DeezerExpirationDateKey"
        static let deezerUserIdKey = "DeezerUserIdKey"
    }
    
    struct AppKey {
        //CHANGE THE VALUE WITH YOUR APP ID
        static let appId = "326682"
    }
    
}

// MARK: - DeezerSessionDelegate Methods

extension DeezerManager: DeezerSessionDelegate {
    
    func deezerDidLogin() {
    
        
        loginResult?(.success)
    }
    
    func deezerDidNotLogin(_ cancelled: Bool) {
        
    }
    
    func deezerDidLogout(){
        
        loginResult?(.logout)
    }
}

// MARK: - DZRObjectListData

extension DeezerManager {
    
    /**
     *   Get all objects of an DZRObjectList
     *
     *   - Parameters fromObjectList: the object containing all objects
     *   - Parameters callback: ([Any]?, Error?)
     **/
    
    func getData(fromObjectList: DZRObjectList, callback: @escaping (_ data: [Any]?, _ error: Error?) -> Void) {
        fromObjectList.allObjects(with: DZRRequestManager.default(), callback: callback)
    }
    
    /**
     *   Get a specific object with an identifier
     *
     *   - Parameters identifier: The string corresponding of the query
     *   - Parameters callback: (Any?, Error?)
     **/
    
    func getObject(identifier: String, callback: @escaping (_ object: Any?, _ error: Error?) -> Void) {
        DZRObject.object(withIdentifier: identifier, requestManager: DZRRequestManager.default(), callback: callback)
    }
    
}

// MARK: - DZRUser get data (Playlist / Album etc ...)

extension DeezerManager {
    
    /**
     *    Get object list of corresponding object for example:
     *      Playlist        ->      Tracks
     *      Album           ->      Tracks
     *      Artist          ->      Album
     *      Mix             ->      Tracks
     *
     *    - Parameters object: The object to get the object list
     *    - Parameters callback: The callback of the request DeezerObjectListRequest (DZRObjectList?, Error?)
     *
     **/
 
    
    /**
     *   Get the current user connected
     *
     *   - Parameters callback: (DZRUser?, Error?)
     *
     **/
    
    func getMe(callback: @escaping (DZRUser?, Error?) -> ()) {
        DZRUser.object(withIdentifier: "me", requestManager: DZRRequestManager.default(), callback: { (user, error) in
            guard let user = user as? DZRUser else {
                callback(nil, error)
                return
            }
            callback(user, error)
        })
    }
}

// MARK: - Search for every kind of data

extension DeezerManager {
    
    /**
     *   Search a DeezerObjectList corresponding to the type and the query. (DZRAlbum / DZRPlaylist / DZRArtist / DZRTrack)
     *
     *   - Parameters type: The type corresponding to the search (default = track)
     *   - Parameters query: The string corresponding of the query
     *   - Parameters completion: The completion of the request DeezerObjectListRequest (DZRObjectList?, Error?)
     **/
    
    func search(type: DZRSearchType = .track, query: String, callback: @escaping DeezerObjectListRequest) {
        DZRObject.search(for: type, withQuery: query, requestManager: DZRRequestManager.default(), callback: callback)
    }
    
}

// MARK: - Track

extension DeezerManager {
    
    /**
     *   Get data of track like the artist / album etc ...
     *
     *   - Parameters track: The track corresponding
     *   - Parameters callback: ([AnyHashable : Any]?, Error?)
     *
     *   Example of the data you can with the corresponding key
     *      DZRPlayableObjectInfoReadable = isReadable
     *      DZRPlayableObjectInfoName = Title
     *      DZRPlayableObjectInfoCreator = Artist Name
     *      DZRPlayableObjectInfoSource = Album Title
     *      DZRPlayableObjectInfoDuration = Duration
     *      DZRPlayableObjectInfoAlternative = Alternative DZRTrack
     *      DZRPlayableObjectInfoAlternativeReadable = isReadable alternative DZRTrack
     **/
    
    func getData(track: DZRTrack, callback: @escaping ([AnyHashable : Any]?, Error?) -> ()) {
        track.playableInfos(with: DZRRequestManager.default()) { (data, error) in
            guard let data = data else {
                callback(nil, error)
                return
            }
            callback(data, nil)
        }
    }
    
    /**
     *   Get illustation of one track
     *
     *   - Parameters track: The track corresponding
     *   - Parameters completion: (UIImage?, Error?)
     **/
    
    func getIllustration(track: DZRTrack, callback: @escaping (UIImage?, Error?) -> ()) {
        track.illustration(with: DZRRequestManager.default(), callback: callback)
    }
    
}


class DeezerManager1 {
    
    static func search(searchType: String, query: String, index: String, completion: @escaping ([String: Any]? , Error?) -> ()) {
        var components = URLComponents(string: "https://api.deezer.com/search/\(searchType)")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "index", value: index)
        ]
        let url = components?.url
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, err) in
            if err != nil {
                completion(nil, err)
                return
            }
            if data != nil {
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                    completion(result, nil)
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
}
