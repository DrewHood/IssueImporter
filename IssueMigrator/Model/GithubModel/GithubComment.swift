//
//  GithubComment.swift
//  IssueMigrator
//
//  Created by Drew R. Hood on 3/13/18.
//  Copyright © 2018 Drew R. Hood. All rights reserved.
//

import Foundation

struct GithubComment: Codable {
    let created_at: String
    let body: String
}
