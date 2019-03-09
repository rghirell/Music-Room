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
    
    @IBOutlet var displayName: UILabel!
    var delegate: FriendCellDelegate!
    var index: Int!
    var isFriend = false {
        didSet {
            changeFriendButton()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
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
