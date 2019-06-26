//
//  PostListViewController.swift
//  Post
//
//  Created by Timothy Rosenvall on 6/24/19.
//  Copyright © 2019 Timothy Rosenvall. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PostController.sharedInstance.fetchPosts {
            DispatchQueue.main.async {
                self.tableViewOutlet.reloadData()
            }
        }
        self.tableViewOutlet.delegate = self
        self.tableViewOutlet.dataSource = self
        tableViewOutlet.estimatedRowHeight = 45
        tableViewOutlet.rowHeight = UITableView.automaticDimension
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        tableViewOutlet.refreshControl = refreshControl
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        presentNewPost()
        PostController.sharedInstance.fetchPosts {
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.sharedInstance.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = PostController.sharedInstance.posts[indexPath.row]
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(post.username) \(post.timestamp)"
        return cell
    }
    
    @objc func refreshControlPulled() {
        PostController.sharedInstance.fetchPosts() {
            DispatchQueue.main.async {
                self.reloadTableViews()
                self.refreshControl.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }

    func reloadTableViews() {
        DispatchQueue.main.async {
            self.tableViewOutlet.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    func presentNewPost() {
        let alertController = UIAlertController(title: "New Post", message: "Post a new message", preferredStyle: .alert)
        alertController.addTextField{ (textField) in textField.placeholder = "Username..." }
        alertController.addTextField{ (textField) in textField.placeholder = "Message..." }
        let addItemAction = UIAlertAction(title: "Add", style: .default) { (_) in guard let usernameText = alertController.textFields?.first?.text, let messageText = alertController.textFields?.last?.text else {return}
            PostController.sharedInstance.addNewPostWith(username: usernameText, text: messageText, completion: {
                DispatchQueue.main.async {
                    self.tableViewOutlet.reloadData()
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addItemAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension PostListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= PostController.sharedInstance.posts.count - 1 {
            PostController.sharedInstance.fetchPosts(reset: false) {
                DispatchQueue.main.async {
                    self.tableViewOutlet.reloadData()
                }
            }
        }
    }
}
