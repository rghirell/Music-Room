//
//  JSONCodable.swift
//  Music-room
//
//  Created by raphael ghirelli on 1/25/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import Foundation


struct User : Codable {
    var email: String
    var password: String
    var displayName: String
}

struct Playlist : Codable {
    var Name: String
    var accessibility : Accessibility
    var creator_name: String
    var follower: [String]
    var genre: String
    var owner: String
    var titles: [String]
    var id: String
}

struct Accessibility : Codable {
    var friends: Bool
    var permission: Bool
    
    enum CodingKeys: String, CodingKey {
        case friends
        case permission = "public"
    }
    
}


struct ArtistArray : Codable {
    var data: [ArtistCodable]
    var total: Int
}

struct ArtistCodable : Codable {
    var name: String
    var picture_small: String
    var picture_medium: String
}


struct FacebookProfileContainer : Codable {
    var facebookProfile : FacebookProfile
}

struct FacebookProfile : Codable {
    var email: String
    var name: String
    var id: String
    var picture: DataFacebookPicture
}

struct DataFacebookPicture : Codable {
    var data: FacebookPicture
}

struct FacebookPicture : Codable {
    var height: Int
    var width: Int
    var url: String
    func changeValues(url: String?) -> FacebookPicture {
        return FacebookPicture(height: self.height, width: self.width, url: url ?? self.url)
    }
}

struct JSON {
    static let encoder = JSONEncoder()
}

extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary[key]
    }
    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSON.encoder.encode(self))) as? [String: Any] ?? [:]
    }
}
