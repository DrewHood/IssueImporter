//
//  GithubIssueWrapper.swift
//  IssueMigrator
//
//  Created by Drew R. Hood on 3/13/18.
//  Copyright © 2018 Drew R. Hood. All rights reserved.
//

import Foundation

struct GithubIssueWrapper: Codable {
    let issue: GithubIssue
    let comments: [GithubComment]?
    
    init(issue: GithubIssue) {
        self.comments = issue.comments
        
        var cleanedIssue = issue
        cleanedIssue.comments = nil
        self.issue = cleanedIssue
    }
}
