//
//  MixedModel.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/8/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import Foundation
import UIKit

struct MixedModel {
    var type: String
    var name: String
    var preview: String?
    var album: AlbumCodable?
    var artist: ArtistCodable?
    var track: TrackCodable?
    var picture: UIImage
    var recordType: String?
    var tracklist: String?
    var id: Int?
  
    
    init(type: String, name: String, picture: UIImage) {
        self.type = type
        self.name = name
        self.picture = picture
    }
    
    init(type: String, name: String, picture: UIImage, id: Int) {
        self.type = type
        self.name = name
        self.picture = picture
        self.id = id
    }
    
    init(type: String, name: String, picture: UIImage, preview: String, album: AlbumCodable, artist: ArtistCodable, track: TrackCodable) {
        self.init(type: type, name: name, picture: picture)
        self.album = album
        self.artist = artist
        self.preview = preview
        self.track = track
    }
    
    init(type: String, name: String, picture: UIImage, artist: ArtistCodable, recordType: String, tracklist: String) {
        self.init(type: type, name: name, picture: picture)
        self.artist = artist
        self.recordType = recordType
        self.tracklist = tracklist
    }
    
}
