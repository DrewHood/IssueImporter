//
//  GitlabObject.swift
//  IssueMigrator
//
//  Created by Drew R. Hood on 3/13/18.
//  Copyright © 2018 Drew R. Hood. All rights reserved.
//

import Foundation

protocol GitlabObject: Codable {
    var id: Int { get }
}
