//
//  TabBarController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/6/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let searchViewController = SearchTableViewController()
        searchViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        let tabBarList = [ searchViewController ]
        viewControllers = tabBarList
        // Do any additional setup after loading the view.
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
