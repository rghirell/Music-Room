//
//  DeezerManager.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/25/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import Foundation


class DeezerManager {
    
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
