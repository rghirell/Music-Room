//
//  File.swift
//  Music-room
//
//  Created by raphael ghirelli on 2/13/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import Foundation

struct keys {
    static let currentTrackViewHeight: CGFloat = 60
}


//    fileprivate func cancelDownloadingImage(forItemAtIndex index: Int) {
//        let url = URL(string: (fetchedArtist?.data[index].picture_medium)!)
//        // Find a task with given URL, cancel it and delete from `tasks` array.
//        guard let taskIndex = tasks.index(where: { $0.originalRequest?.url == url }) else {
//            return
//        }
//        let task = tasks[taskIndex]
//        task.cancel()
//        tasks.remove(at: taskIndex)
//    }

//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(page)
//        if fetchedArtist == nil || page >= (fetchedArtist?.total)! - 25 {
//            print(page)
//            return
//        }
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//
//        if offsetY > contentHeight - scrollView.frame.height * 4 {
//            print("inside", fetchingMore)
//            if !fetchingMore {
//                print("fetching")
//                page = page + 25
//                fetchNewData(page: page)
//                fetchingMore = !fetchingMore
//            }
//        }
//    }


//func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//    //        indexPaths.forEach { self.downloadImage(forItemAtIndex: $0.row) }
//}
//
//func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
//    //        indexPaths.forEach { self.cancelDownloadingImage(forItemAtIndex: $0.row) }
//}


//    var page = 0
//    var fetchingMore = false

//
//    fileprivate func fetchNewData(page: Int) {
//        var components = URLComponents(string: "https://api.deezer.com/search/artist")
//        components?.queryItems = [
//            URLQueryItem(name: "q", value: self.search),
//            URLQueryItem(name: "index", value: "\(page)")
//        ]
//        let url = components?.url
////        let url = URL(string: "https://api.deezer.com/search/artist?q=\(self.search)&index=\(page)")
//        var request = URLRequest(url: url!)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "GET"
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if error != nil {
//                print(error?.localizedDescription)
//                return
//            }
//            do {
//                let result = try JSONDecoder().decode(ArtistArray.self, from: data!)
//                self.dataFetched = result
//            } catch {
//                print(error)
//            }
//        }
//        task.resume()
//    }

//
//    fileprivate func downloadImage(forItemAtIndex index: Int, urlImage: String?) {
//        if finalResult.count <= 0 {
//            return
//        }
//        let url = URL(string: urlImage!)
//        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
//            // Perform UI changes only on main thread.
//            DispatchQueue.main.async {
//                if let data = data, let image = UIImage(data: data) {
//                    self.imageCache.setObject(image, forKey: urlImage! as AnyObject)
//                    let indexPath = IndexPath(row: index, section: 0)
//                    self.tableView.reloadData()
//                }
//            }
//        }
//        task.resume()
//    }
