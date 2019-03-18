//
//  ParentTableViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/25/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Kingfisher
import JGProgressHUD

class ParentTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let imageCache = NSCache<AnyObject, AnyObject>()
    var result = [[String: Any]]()
    var player: PlayerViewController!
    private var page = 0
    private var totalIndex = 0
    var search: String!
    var searchType: String!
    private var fetchingMore = false
    var tableView: UITableView!
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.interactionType = .blockAllTouches
        hud.parallaxMode = .alwaysOff
        return hud
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        hud.show(in: view)
        fetchFromApi()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if result.count <= 0  && !hud.isVisible {
            tableView.setEmptyMessage("No results")
        } else {
            self.tableView.restore()
        }
        return result.count
    }
        
    private func fetchFromApi() {
        DeezerManager.search(searchType: searchType, query: self.search, index: page.description) { (result, err) in
            DispatchQueue.main.async {
                Helpers.dismissHud(self.hud, text: "", detailText: "", delay: 0)
            }
            if err != nil {
                let alert = Alert.errorAlert(title: "Error", message: err!.localizedDescription)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            if result != nil {
                self.result += result!["data"] as! [[String: Any]]
                self.totalIndex = result!["total"] as! Int
                self.page += 25
                self.fetchingMore = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if page >= totalIndex - 25 || fetchingMore {
            return
        }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height * 1.4 {
            if !fetchingMore {
                print("fetching")
                fetchFromApi()
                fetchingMore = !fetchingMore
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    

}
