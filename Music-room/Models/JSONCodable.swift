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

struct EventPlaylistCreation : Codable {
    var Name: String
    var genre: String
    var start: Int
    var end: Int
    var lon: Double
    var lat: Double
    var distance: Int
}

struct Accessibility : Codable {
    var permission: Bool
    var friends: Bool?
    
    enum CodingKeys: String, CodingKey {
        case friends
        case permission = "public"
    }
}

struct SearchRequest<T : Codable>: Codable {
    let data: [T]
    var total: Int
}

struct ArtistCodable: Codable {
    let name: String
    let id: Int
    let picture, link: String?
    let pictureSmall, pictureMedium, pictureBig, pictureXl: String?
    let nbAlbum, nbFan: Int?
    let radio: Bool?
    let tracklist: String
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, link, picture
        case pictureSmall = "picture_small"
        case pictureMedium = "picture_medium"
        case pictureBig = "picture_big"
        case pictureXl = "picture_xl"
        case nbAlbum = "nb_album"
        case nbFan = "nb_fan"
        case radio, tracklist, type
    }
}

struct AlbumCodable: Codable {
    let title: String?
    let id: Int
    let cover: String
    let link: String?
    let coverSmall, coverMedium, coverBig, coverXl: String?
    let genreID, nbTracks: Int?
    let recordType: String?
    let tracklist: String
    let explicitLyrics: Bool?
    let artist: ArtistCodable?
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, link, cover
        case coverSmall = "cover_small"
        case coverMedium = "cover_medium"
        case coverBig = "cover_big"
        case coverXl = "cover_xl"
        case genreID = "genre_id"
        case nbTracks = "nb_tracks"
        case recordType = "record_type"
        case tracklist
        case explicitLyrics = "explicit_lyrics"
        case artist, type
    }
}

struct TrackCodable: Codable {
    let id: Int
    let readable: Bool?
    let title, titleShort, titleVersion: String?
    let link: String?
    let rank: Int?
    let duration: Int
    let explicitLyrics: Bool?
    let explicitContentLyrics, explicitContentCover: Int?
    let preview: String
    let artist: ArtistCodable?
    let album: AlbumCodable?
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case id, readable, title
        case titleShort = "title_short"
        case titleVersion = "title_version"
        case link, duration, rank
        case explicitLyrics = "explicit_lyrics"
        case explicitContentLyrics = "explicit_content_lyrics"
        case explicitContentCover = "explicit_content_cover"
        case preview, artist, album, type
    }
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
struct RegisterData : Codable {
    var accessibility : Accessibility
    var displayName : String
    var friends : [String]
    var is_linked_to_deezer : Bool
    var is_linked_to_facebook : Bool
    var is_linked_to_google : Bool
    var pref_music : [String]
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
