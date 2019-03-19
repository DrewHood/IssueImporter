# IssueImporter
Transfer issues from your Gitlab repository to your Github repo, written in Swift.

Open up main.swift and fill in the relevant credentials and urls for the issues you wish to migrate:
- GITLAB_API_BASE
- GITLAB_API_TOKEN
- GITLAB_SOURCE_PROJECT_ID
- GITHUB_REPO
- GITHUB_API_TOKEN

In the current configuration, this script can only move issues **FROM Gitlab TO Github**. To enable bidirectional transfers refactoring would be needed, but it shouldn't be too difficult.

For this project I used Xcode but there's no reason this can't be compiled by swiftc on linux if a port is desired.
