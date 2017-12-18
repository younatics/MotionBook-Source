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
    @objc dynamic var title: String?
    @objc dynamic var author: String?
    @objc dynamic var type: String?
    @objc dynamic var detail: String?
    @objc dynamic var gifUrl: String?
    @objc dynamic var gitUrl: String?
    @objc dynamic var license: String?
    @objc dynamic var language: String?
    @objc dynamic var authorImageUrl: String?
    @objc dynamic var mainColor: String?
    @objc dynamic var gitStar: Int = 0
    @objc dynamic var forkCount: Int = 0
    @objc dynamic var openIssuesCount: Int = 0
    @objc dynamic var subscribersCount: Int = 0
    @objc dynamic var updatedDate = NSDate()
    @objc dynamic var gifData = NSData()
    @objc dynamic var pngData = NSData()
    @objc dynamic var cocoapodsInstall: Bool = false
    @objc dynamic var carthageInstall: Bool = false
    @objc dynamic var availableLibrary: Bool = false
    @objc dynamic var favorite: Bool = false
    
    override static func primaryKey() -> String? {
        return "title"
    }
}

class LibraryDataTypeModel: Object {
    @objc dynamic var type: String?
    
    override static func primaryKey() -> String? {
        return "type"
    }

}

class UserModel: Object {
    @objc dynamic var user: String?
    @objc dynamic var company: String?
    @objc dynamic var blog: String?
    @objc dynamic var bio: String?
    @objc dynamic var type: String?
    @objc dynamic var avatar_url: String?
    @objc dynamic var location: String?
    @objc dynamic var followers: Int = 0
    @objc dynamic var following: Int = 0
    @objc dynamic var public_repos: Int = 0
    
    override static func primaryKey() -> String? {
        return "user"
    }

}

