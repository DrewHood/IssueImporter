//
//  GitlabComment.swift
//  IssueMigrator
//
//  Created by Drew R. Hood on 3/13/18.
//  Copyright © 2018 Drew R. Hood. All rights reserved.
//

import Foundation

struct GitlabComment: GitlabObject {
    let id: Int
    let created_at: String
    let updated_at: String
    let body: String
}
