//
//  FriendsTableViewCell.swift
//  Music-room
//
//  Created by raphael ghirelli on 3/9/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

protocol FriendCellDelegate: class {
    func addOrRemoveFriend(index: Int, add: Bool)
}

class FriendsTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var displayName: UILabel!
    var delegate: FriendCellDelegate!
    var index: Int!
    var isFriend = false {
        didSet {
            changeFriendButton()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func addOrRemoveFriend(_ sender: UIButton) {
        delegate.addOrRemoveFriend(index: index, add: !isFriend)
        isFriend = !isFriend
    }
    
    
    @IBOutlet weak var friendButton: UIButton!
    private func changeFriendButton() {
        if friendButton == nil { return }
        if isFriend {
            friendButton.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        } else {
            friendButton.setImage(#imageLiteral(resourceName: "addFriend"), for: .normal)
        }
    }
    
    
}
