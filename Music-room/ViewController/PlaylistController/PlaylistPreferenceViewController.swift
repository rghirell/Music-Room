//
//  PlaylistPreferenceViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 3/8/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

class PlaylistPreferenceViewController: UIViewController {

//    override func loadView() {
//        Bundle.main.loadNibNamed("PlaylistPreferenceViewController", owner: self, options: nil)
//    }
    
    var playlistUID: String!
    var type: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        // Do any additional setup after loading the view.
    }

    @IBAction func `do`(_ sender: UIButton) {
        let vc = AddFriendTableViewController()
        vc.playlistUID = self.playlistUID
        vc.type = self.type
        self.addChild(vc)
        guard let vi = view.viewWithTag(1) else { return }
        vc.view.frame = CGRect(x: 0, y: 0, width: vi.frame.width, height: vi.frame.height)
        self.view.viewWithTag(1)!.addSubview(vc.view)
        vc.didMove(toParent: self)
//        show(vc, sender: self)
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
