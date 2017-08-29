//
//  LibraryDataModel.swift
//  motion-book
//
//  Created by YiSeungyoun on 2017. 2. 20..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation
import RealmSwift

class LibraryDataModel: Object {
    dynamic var title: String?
    dynamic var author: String?
    dynamic var type: String?
    dynamic var detail: String?
    dynamic var gifUrl: String?
    dynamic var gitUrl: String?
    dynamic var license: String?
    dynamic var language: String?
    dynamic var authorImageUrl: String?
    dynamic var mainColor: String?
    dynamic var gitStar: Int = 0
    dynamic var forkCount: Int = 0
    dynamic var openIssuesCount: Int = 0
    dynamic var subscribersCount: Int = 0
    dynamic var updatedDate = NSDate()
    dynamic var gifData = NSData()
    dynamic var pngData = NSData()
    dynamic var cocoapodsInstall: Bool = false
    dynamic var carthageInstall: Bool = false
    dynamic var availableLibrary: Bool = false
    dynamic var favorite: Bool = false
    
    override static func primaryKey() -> String? {
        return "title"
    }
}

class LibraryDataTypeModel: Object {
    dynamic var type: String?
    
    override static func primaryKey() -> String? {
        return "type"
    }

}

class UserModel: Object {
    dynamic var user: String?
    dynamic var company: String?
    dynamic var blog: String?
    dynamic var bio: String?
    dynamic var type: String?
    dynamic var avatar_url: String?
    dynamic var location: String?
    dynamic var followers: Int = 0
    dynamic var following: Int = 0
    dynamic var public_repos: Int = 0
    
    override static func primaryKey() -> String? {
        return "user"
    }

}

