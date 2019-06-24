//
//  PostController.swift
//  Post
//
//  Created by Timothy Rosenvall on 6/24/19.
//  Copyright © 2019 Timothy Rosenvall. All rights reserved.
//

import Foundation

class PostController {
    
    static let sharedInstance = PostController()
    let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts")
    var posts: [Post] = []
    
    func fetchPosts (completion: @escaping() -> Void) {
        guard let url = baseURL else { completion(); return }
        let getterEndpoint = url.appendingPathExtension("json")
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print(error)
                completion()
                return
            } else {
                guard let data = data else {completion(); return}
                do {
                    let decoder = JSONDecoder()
                    let postsDictionary = try decoder.decode([String:Post].self, from: data)
                    var posts = postsDictionary.compactMap({$0.value})
                    posts.sort(by: { $0.timestamp > $1.timestamp })
                    self.posts = posts
                    completion()
                } catch {
                    print("OH NO!!! EVERYTHING IS EXPLODING!!! \(error.localizedDescription.uppercased())")
                    completion()
                    return
                }
            }
        }
        dataTask.resume()
    }
}
