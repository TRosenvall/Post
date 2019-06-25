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
        PostController.sharedInstance.fetchPosts {
            DispatchQueue.main.async {
                self.reloadTableViews()
                self.refreshControl.endRefreshing()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }

    func reloadTableViews () {
        DispatchQueue.main.async {
            self.tableViewOutlet.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
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
