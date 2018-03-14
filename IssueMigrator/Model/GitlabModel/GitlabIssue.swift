//
//  GitlabIssue.swift
//  IssueMigrator
//
//  Created by Drew R. Hood on 3/13/18.
//  Copyright © 2018 Drew R. Hood. All rights reserved.
//

import Foundation

struct GitlabIssue: GitlabObject {
    
    enum IssueStatus: String, Codable {
        case open = "opened"
        case closed = "closed"
    }
    
    let id: Int
    /// ID of the issue within the project
    let iid: Int
    let project_id: Int
    let title: String
    let description: String
    let assignee: GitlabUser?
    let state: IssueStatus
    let created_at: String
    let updated_at: String
    let user_notes_count: Int
    let labels: [String]?
    
    var comments: [GitlabComment]?
}
