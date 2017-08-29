//
//  CoreData.swift
//  motion-book
//
//  Created by YiSeungyoun on 2017. 2. 11..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation
import RealmSwift

class DataManager: NSObject {
    
    static let shared: DataManager = DataManager()
    
    class func realmMigrationCheck() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 5,
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 5) {
                    
                }
        })
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try! Realm()
    }
    
    func converDate(date: NSDate) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date as Date)
    }
    
    func convertStarCount(count: Int) -> String {
        if count > 1000 {
            let subCount:Int = (count % 1000) / 100
            if subCount != 0 {
                return "\(count/1000).\(subCount)K"
            } else {
                return "\(count/1000)K"
            }
        }
        return "\(count)"
    }
        
    func compareStringAndArray(compareString: String, compareArray: [String] ) -> Bool {
        let compareArrayToString = compareArray.joined(separator: "")
        if compareArrayToString == compareString {
            return true
        }
        return false
    }
    
    func getArrayWithRecognizerString(originArray: [String],startRecognizerString: String, endRecognizerString: String) -> [String] {
        var returnArray = [String]()
        
        let originArrayCount = originArray.count - 20
        let startRecognizerStringCount: Int = startRecognizerString.characters.count
        var partOfArray = [String]()
        for i in 0..<originArrayCount {
            for chartersCount in i..<i + startRecognizerStringCount {
                partOfArray.append(originArray[chartersCount])
            }
            
            if compareStringAndArray(compareString: startRecognizerString, compareArray: partOfArray) {
                var returnValue = ""
                for x in i + startRecognizerStringCount..<originArrayCount {
                    if originArray[x] != endRecognizerString {
                        returnValue = returnValue + originArray[x]
                    } else {
                        returnArray.append(returnValue)
                        break
                    }
                }
            }
            partOfArray = [String]()
        }
        return returnArray
    }
    
    func seperateByObject(string: String, completion: @escaping () -> Void) {
        let stringArray = string.characters.map { String($0) }
        
        let titleArray = self.getArrayWithRecognizerString(originArray: stringArray, startRecognizerString: "#### `", endRecognizerString: "`")
        let authorArray = self.getArrayWithRecognizerString(originArray: stringArray, startRecognizerString: "- Author: ", endRecognizerString: "\n")
        let gitArray = self.getArrayWithRecognizerString(originArray: stringArray, startRecognizerString: "- Git: ", endRecognizerString: "\n")
        let detailArray = self.getArrayWithRecognizerString(originArray: stringArray, startRecognizerString: "- Detail: ", endRecognizerString: "\n")
        let cocoapodsArray = self.getArrayWithRecognizerString(originArray: stringArray, startRecognizerString: "- Cocoapods: ", endRecognizerString: "\n")
        let carthageArray = self.getArrayWithRecognizerString(originArray: stringArray, startRecognizerString: "- Carthage: ", endRecognizerString: "\n")
        let typeArray = self.getArrayWithRecognizerString(originArray: stringArray, startRecognizerString: "- Type: ", endRecognizerString: "\n")
        
        let realm = try! Realm()

        for i in 0..<titleArray.count {
            if let cocoaBool = cocoapodsArray[i].toBool(), let carthageBool = carthageArray[i].toBool() {
                try! realm.write {
                    realm.create(LibraryDataModel.self, value: ["title": titleArray[i], "author": authorArray[i], "gitUrl": gitArray[i], "gifUrl": "https://raw.githubusercontent.com/younatics/motion-book-ios/master/motion-book/\(titleArray[i])/\(titleArray[i]).gif", "detail": detailArray[i], "cocoapodsInstall": cocoaBool, "carthageInstall": carthageBool, "type": typeArray[i]], update: true)

                    realm.create(LibraryDataTypeModel.self, value: ["type": typeArray[i]], update: true)
                }
            }
        }
        completion()

    }
}

