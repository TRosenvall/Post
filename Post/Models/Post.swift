//
//  Post.swift
//  Post
//
//  Created by Timothy Rosenvall on 6/24/19.
//  Copyright © 2019 Timothy Rosenvall. All rights reserved.
//

import Foundation

struct Post: Codable {
    let text: String
    let timestamp: TimeInterval
    let username: String
    
    init(text: String, timestamp: TimeInterval = Date().timeIntervalSince1970, username: String) {
        self.text = text
        self.timestamp = timestamp
        self.username = username
    }
}
