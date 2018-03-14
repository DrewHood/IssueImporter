//
//  main.swift
//  IssueMigrator
//
//  Created by Drew R. Hood on 3/13/18.
//  Copyright © 2018 Drew R. Hood. All rights reserved.
//

import Foundation

/* API path and authentication */
let GITLAB_API_BASE = "you should probably fill this in"
let GITLAB_API_TOKEN = "NiceTry"
let GITHUB_REPO = "pick one?"
let GITHUB_API_TOKEN = "NotSoFast"

/* Source and destination projects */
let GITLAB_SOURCE_PROJECT_ID = 0

let gitlabApi = try! GitlabAPI(host: GITLAB_API_BASE, token: GITLAB_API_TOKEN)

// Get all issues on a project.
var gitlabIssues = [GitlabIssue]()
var i = 1
while true {
    do {
        let issue = try gitlabApi.issue(id: i, inProjectId: GITLAB_SOURCE_PROJECT_ID)
        gitlabIssues.append(issue)
        i += 1
    } catch GitlabAPI.GitlabError.notFound {
        if i < 20 {
            i += 1
            continue
        }
        break
    } catch {
        i += 1
        continue
    }
}

// Now get all the comments.
for j in 0..<gitlabIssues.count {
    if gitlabIssues[j].user_notes_count > 0 {
        do {
            var updatedIssue = gitlabIssues[j]
            updatedIssue.comments = try gitlabApi.comments(forIssueId: updatedIssue.iid, inProjectId: updatedIssue.project_id)
            gitlabIssues[j] = updatedIssue
        } catch {
            debugPrint(error)
        }
    }
}

// Now create Github Issues
var githubIssues = [GithubIssue]()

for gitlabIssue in gitlabIssues {
    // Map the Gitlab issue to Github's format.
    let githubIssue = GithubIssue(
        title: gitlabIssue.title,
        body: (gitlabIssue.description == "") ? "&nbsp;" : gitlabIssue.description,
        closed: gitlabIssue.state == .closed,
        created_at: gitlabIssue.created_at,
        updated_at: gitlabIssue.updated_at,
        assignee: gitlabIssue.assignee?.username,
        labels: gitlabIssue.labels,
        comments: gitlabIssue.comments?.map({GithubComment(created_at: $0.created_at, body: $0.body)})
    )
    githubIssues.append(githubIssue)
}

let jsonEncoder = JSONEncoder()
jsonEncoder.outputFormatting = .prettyPrinted

let encodedIssues = try! jsonEncoder.encode(githubIssues)
let jsonString = String(data: encodedIssues, encoding: .utf8)
print(jsonString!)

// Push issues to Github.
let githubApi = GithubAPI(token: GITHUB_API_TOKEN)
var successCount = 0
var failureCount = 0
for issue in githubIssues {
    do {
        try githubApi.create(issue: issue, inRepository: GITHUB_REPO)
        successCount += 1
        print("\(successCount). Created github issue called \(issue.title)!")
    } catch {
        failureCount += 1
        print("\(failureCount). Encountered error creating github issue titled \(issue.title)")
        debugPrint(error)
    }
}
