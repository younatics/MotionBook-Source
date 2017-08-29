//
//  NetworkManager.swift
//  motion-book
//
//  Created by YiSeungyoun on 2017. 2. 11..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift
import FLAnimatedImage
import PickColor

extension JSON {
    public var date: Date? {
        get {
            if let str = self.string {
                return JSON.jsonDateFormatter.date(from: str)
            }
            return nil
        }
    }
    
    private static let jsonDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter
    }()
}

class NetworkManager: NSObject {
    static let shared: NetworkManager = NetworkManager()
    
    func deepLinkUrl(title:String, description:String, url: String, gitUrl: String, completion: @escaping (_ url: String?) -> Void) {
        let androidInfo = [
            "androidFallbackLink" : gitUrl
        ]
        
        let iosInfo = [
            "iosBundleId": "com.seungyounyi.MotionBook",
            "iosFallbackLink": "https://appsto.re/kr/8yv1hb.i",
            "iosCustomScheme": "motionbook",
            "iosIpadFallbackLink": "https://appsto.re/kr/8yv1hb.i",
            "iosAppStoreId": "1205163580"
        ]
        
        let navigationInfo = [
            "enableForcedRedirect": true
        ]
        
        let fullDescription = "\(description)\n See more information and example in MotionBook"
        
        let socialMetaTagInfo = [
            "socialTitle": title,
            "socialDescription": fullDescription,
            "socialImageLink": url
        ]
        
        let suffix = [
            "option": "SHORT"
        ]
        
        let dynamicLinkInfo = [
            "dynamicLinkDomain": "hjy94.app.goo.gl",
            "link": "\(gitUrl)?title=\(title)",
            "androidInfo": androidInfo,
            "iosInfo": iosInfo,
            "navigationInfo":navigationInfo,
            "socialMetaTagInfo": socialMetaTagInfo
        ] as [String : Any]
        
        let fullParams = [
            "dynamicLinkInfo": dynamicLinkInfo,
            "suffix": suffix
        ]
        
        Alamofire.request("https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=AIzaSyCGeRtK_9FbJBYsFh3NdU_BgTcJv0EJyx4", method: .post, parameters: fullParams, encoding: JSONEncoding.default)
        .responseJSON { (response) in
            if response.error != nil {
                completion(nil)
                return
            }
            
            if let jsonAlmofire = response.result.value {
                let json = JSON(jsonAlmofire)
                let shortLink = json["shortLink"].string

                completion(shortLink)
            }
        }
        
    }
    
    func getInitialData(comletion: @escaping (_ error: String?) -> Void) {
        Alamofire.request("https://raw.githubusercontent.com/younatics/MotionBook/master/README.md").responseString { response in
            if let error = response.error {
                comletion(error.localizedDescription)
                return
            }
//            print(response.error ?? "No Error")
//            print(response.description)
//            print(response.result.value ?? "No result")
            if let initialString = response.result.value{
                DataManager.shared.seperateByObject(string: initialString, completion: { 
                    comletion(nil)
                })
            }
        }
    }

    func downloadImage(title: String, url: URL, completion: @escaping (_ error: String?) -> Void) {
        ODRManager.shared.requestDataWith(tag: title, onSuccess: {
            
            if let bundlePath = Bundle.main.path(forResource: title, ofType: "gif") {
                do {
                    let data = try NSData(contentsOf: URL(fileURLWithPath: bundlePath)) as Data
                    guard let image = FLAnimatedImage(gifData: data), let posterImage = image.posterImage else { return }
                    let hexColor = posterImage.pickColorHexstring()
                    let pngData = UIImagePNGRepresentation(posterImage)
                    
                    let realm = try! Realm()
                    
                    try! realm.write {
                        realm.create(LibraryDataModel.self, value: ["title": title, "gifData": data, "pngData": pngData ?? Data(), "mainColor": hexColor], update: true)
                        completion(nil)
                        
                    }

                } catch {
                    completion(error.localizedDescription)
                }
            }
            
            
        }) { (error) in
            switch error.code {
            case NSBundleOnDemandResourceOutOfSpaceError:
                completion("You don't have enough space available to download this resource.")
            case NSBundleOnDemandResourceExceededMaximumSizeError:
                completion("The bundle resource was too big.")
            case NSBundleOnDemandResourceInvalidTagError:
                let realm = try! Realm()
                let object = realm.object(ofType: LibraryDataModel.self, forPrimaryKey: (title))
                guard let _object = object else { return completion("The requested tag does not exist.") }
                
                try! realm.write {
                    realm.delete(_object)
                    completion(nil)
                }
                
            default:
                completion(error.description)
            }
        }
    }
    
    func updateLibraryData(completion: @escaping (_ error: String?) -> Void) {
        let realm = try! Realm()
        
        let gitArray = realm.objects(LibraryDataModel.self)
        for i in 0..<gitArray.count  {
            if let author = gitArray[i].author, let title = gitArray[i].title {
                let gitUrl = "\(author)/\(title)"
                
                let user = "younatics"
                let token = "b908fde1073fb488eeee32b9213c0542b410876a"
                let credentialData = "\(user):\(token)".data(using: String.Encoding.utf8)!
                let base64Credentials = credentialData.base64EncodedString(options: [])
                let headers = ["Authorization": "Basic \(base64Credentials)"]
                
                Alamofire.request("https://api.github.com/repos/\(gitUrl)", method: .get, headers:headers).responseJSON { response in
                    if let error = response.error {
                        completion(error.localizedDescription)
                        return
                    }

                    if let jsonAlmofire = response.result.value {
                        let json = JSON(jsonAlmofire)
                        
                        let starCount = json["watchers_count"].intValue
                        let updatedDate = json["pushed_at"].date
                        let openIssuesCount = json["open_issues_count"].intValue
                        let subscribersCount = json["subscribers_count"].intValue
                        let language = json["language"].string
                        let forkCount = json["forks_count"].intValue
                        let authorImageUrl = json["owner"]["avatar_url"].string
                        
                        if let _updatedDate = updatedDate {
                            if starCount != 0 {
                                try! realm.write {
                                    realm.create(LibraryDataModel.self, value: ["title": title, "gitStar": starCount, "subscribersCount": subscribersCount, "updatedDate": _updatedDate, "openIssuesCount": openIssuesCount, "language": language ?? "", "forkCount": forkCount, "authorImageUrl": authorImageUrl ?? ""], update: true)
                                }
                            }
                        }
                        
                        if i == gitArray.count - 1 {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    func updateUserData(completion: @escaping (_ error: String?) -> Void) {
        let realm = try! Realm()
        
        let gitArray = realm.objects(LibraryDataModel.self)
        for i in 0..<gitArray.count  {
            if let author = gitArray[i].author {
                let userUrl = "\(author)"
                
                let user = "younatics"
                let token = "b908fde1073fb488eeee32b9213c0542b410876a"
                let credentialData = "\(user):\(token)".data(using: String.Encoding.utf8)!
                let base64Credentials = credentialData.base64EncodedString(options: [])
                let headers = ["Authorization": "Basic \(base64Credentials)"]
                
                Alamofire.request("https://api.github.com/users/\(userUrl)", method: .get, headers:headers).responseJSON { response in
                    if let error = response.error {
                        completion(error.localizedDescription)
                        return
                    }

                    if let jsonAlmofire = response.result.value {
                        let json = JSON(jsonAlmofire)
                        let company = json["company"].string
                        let blog = json["blog"].string
                        let bio = json["bio"].string
                        let type = json["type"].string
                        let avatar_url = json["avatar_url"].string
                        let location = json["location"].string
                        let followers = json["followers"].intValue
                        let following = json["following"].intValue
                        let public_repos = json["public_repos"].intValue
                        
                        try! realm.write {
                            realm.create(UserModel.self, value: ["user": userUrl, "company": company ?? "", "avatar_url": avatar_url ?? "", "blog": blog ?? "", "bio": bio ?? "", "type": type ?? "", "location": location ?? "", "followers": followers,"following": following, "public_repos": public_repos], update: true)
                        }
                        
                        if i == gitArray.count - 1 {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }

    
    func updateGithubLicense(completion: @escaping (_ error: String?) -> Void) {
        let realm = try! Realm()
        
        let gitArray = realm.objects(LibraryDataModel.self)
        for i in 0..<gitArray.count  {
            if let author = gitArray[i].author, let title = gitArray[i].title {
                let gitUrl = "\(author)/\(title)"
                
                let user = "younatics"
                let token = "b908fde1073fb488eeee32b9213c0542b410876a"
                let credentialData = "\(user):\(token)".data(using: String.Encoding.utf8)!
                let base64Credentials = credentialData.base64EncodedString(options: [])
                let headers = ["Authorization": "Basic \(base64Credentials)"]
                
                Alamofire.request("https://api.github.com/repos/\(gitUrl)/license", method: .get, headers:headers).responseJSON { response in
                    if let error = response.error {
                        completion(error.localizedDescription)
                        return
                    }

                    if let jsonAlmofire = response.result.value {
                        let json = JSON(jsonAlmofire)
                        
                        let license = json["license"]["name"].string
                        
                        if let _license = license {
                                try! realm.write {
                                    realm.create(LibraryDataModel.self, value: ["title": title, "license": _license], update: true)
                                }
                        }
                        
                        if i == gitArray.count - 1 {
                            completion(nil)
                        }
                    }
                }
            }
        }
        
    }

}

