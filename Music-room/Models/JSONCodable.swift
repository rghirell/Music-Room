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
    var genre: String?
    var distance: Int?
    var owner: String
    var titles: [TitleInfo?]?
}

struct TitleInfo : Codable {
    var album : AlbumCodable
    var artist : ArtistCodable
    var title: String
    var title_short: String
    var type: String
    var preview: String
    var in_Event: Bool?
}


struct Accessibility : Codable {
    var permission: Bool
    
    enum CodingKeys: String, CodingKey {
        case permission = "public"
    }
    
}


struct ArtistArray : Codable {
    var data: [ArtistCodable]
    var total: Int
}

struct ArtistCodable : Codable {
    var name: String
    var type: String
    var picture_medium: String?
    var picture_xl: String?
    var id: Int
}


struct TrackArray : Codable {
    var data : [TrackCodable]
    var total : Int
}

struct TrackCodable : Codable {
    var title: String
    var preview: String
    var type : String
    var album : AlbumCodable?
    var artist : ArtistCodable
    var duration : Int?
}


struct AlbumArray : Codable {
    var data: [AlbumCodable]
    var total: Int
}

struct AlbumCodable : Codable {
    var title: String
    var cover_xl: String?
    var cover_medium: String?
    var cover_big: String?
    var tracklist: String
    var record_type: String?
    var type: String
    var artist: ArtistCodable?
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
