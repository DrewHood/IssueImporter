//
//  GithubIssue.swift
//  IssueMigrator
//
//  Created by Drew R. Hood on 3/13/18.
//  Copyright © 2018 Drew R. Hood. All rights reserved.
//

import Foundation

struct GithubIssue: Codable {
    let title: String
    let body: String
    let closed: Bool
    let created_at: String
    let updated_at: String
    let assignee: String?
    let labels: [String]?
    var comments: [GithubComment]?
}
