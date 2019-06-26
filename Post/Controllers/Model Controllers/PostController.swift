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
    
    func fetchPosts (reset: Bool = true, completion: @escaping() -> Void) {
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.timestamp ?? Date().timeIntervalSince1970
        var getterEndpoint: URL
        guard let url = baseURL else { completion(); return }
        let urlParameters = [ "orderBy": "\"timestamp\"", "endAt": "\(queryEndInterval)", "limitToLast": "15", ]
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        guard let aURLConstant = urlComponents?.url else {completion(); return}
        getterEndpoint = aURLConstant.appendingPathExtension("json")
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
                    if reset == true {
                        self.posts = posts
                    } else {
                        self.posts.append(posts[0])
                    }
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
    
    func addNewPostWith (username: String, text: String, completion: @escaping () -> Void) {
        let newPost = Post(text: text, timestamp: Date().timeIntervalSince1970, username: username)
        var postData: Data
        do {
            let encoder = JSONEncoder()
            postData = try encoder.encode(newPost)
            guard let baseURL = URL(string: "https://devmtn-posts.firebaseio.com/posts") else {completion(); return}
            let postEndpoint = baseURL.appendingPathExtension("json")
            var request = URLRequest(url: postEndpoint)
            request.httpBody = postData
            request.httpMethod = "Post"
            URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let error = error {
                    print(error.localizedDescription)
                    completion(); return
                }
                if let data = data {
                    let stringData = String(data: data, encoding: .utf8)
                    print("Success, \(stringData!)")
                    self.posts.insert(newPost, at: 0)
                    self.fetchPosts {
                        completion(); return
                    }
                }
            }.resume()
        } catch {
            print(error.localizedDescription)
            completion(); return
        }
    }
}
