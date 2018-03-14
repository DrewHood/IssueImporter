//
//  GitlabUser.swift
//  IssueMigrator
//
//  Created by Drew R. Hood on 3/13/18.
//  Copyright © 2018 Drew R. Hood. All rights reserved.
//

import Foundation

struct GitlabUser: GitlabObject {
    let id: Int
    let username: String
    let name: String
}
