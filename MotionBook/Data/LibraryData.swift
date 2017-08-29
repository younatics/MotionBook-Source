//
//  LibraryData.swift
//  animator
//
//  Created by YiSeungyoun on 2017. 2. 9..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation
import RealmSwift

class LibraryData: NSObject {
    var libraryDataTypeModel: Results<LibraryDataTypeModel>?

    override init() {
        super.init()
        
        self.getData()
    }
    
    func getData() {
        let realm = try! Realm()
        self.libraryDataTypeModel = realm.objects(LibraryDataTypeModel.self).sorted(byKeyPath: "type")
        
    }

    // MARK: - Main Data Model
    func getDataWith(title: String) -> LibraryDataModel? {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "title = '\(title)'")

        let data = realm.objects(LibraryDataModel.self).filter(predicate)
        if data.count > 0 {
            return data[0]
        } else {
            return nil
        }
    }
    
    func getArraySectionCount() -> Int {
        return self.libraryDataTypeModel?.count ?? 0
    }
    
    func getDataModelWithIndexPath(indexPath: IndexPath) -> LibraryDataModel {
        return self.getArrayWithSection(section: indexPath.section, isFavorite: false)[indexPath.row]
    }
    
    func getArrayCountWithSection(section: Int) -> Int {
        return self.getArrayWithSection(section: section, isFavorite: false).count
    }
    
    func getTitleOfArrayWithSection(section: Int) -> String {
        if let type = libraryDataTypeModel?[section].type {
            return type
        } else {
            return ""
        }
    }
    
    func getTitles() -> [String] {
        guard let types = libraryDataTypeModel else { return [String]() }
        var titles = [String]()
        titles.append("All")
        
        for type in types {
            guard let type = type.type else { return [String]() }
            titles.append(type)
        }
        return titles
    }
    
    func getArrayWithSection(section: Int, isFavorite: Bool) -> Results<LibraryDataModel> {
        let realm = try! Realm()
        if isFavorite {
            return realm.objects(LibraryDataModel.self).filter("type = '\(self.getTitleOfArrayWithSection(section: section))' AND favorite = true")
        } else {
            return realm.objects(LibraryDataModel.self).filter("type = '\(self.getTitleOfArrayWithSection(section: section))'")
        }
    }
    
    func getArrayWith(section: Int, sorted: Int) -> Results<LibraryDataModel> {
        let realm = try! Realm()
        if sorted == 0 {
            if section == 0 {
                return realm.objects(LibraryDataModel.self).sorted(byKeyPath: "gitStar", ascending: false)
            } else {
                return realm.objects(LibraryDataModel.self).filter("type = '\(self.getTitleOfArrayWithSection(section: section - 1))'").sorted(byKeyPath: "gitStar", ascending: false)
            }
        } else {
            if section == 0 {
                return realm.objects(LibraryDataModel.self).sorted(byKeyPath: "updatedDate", ascending: false)
            } else {
                return realm.objects(LibraryDataModel.self).filter("type = '\(self.getTitleOfArrayWithSection(section: section - 1))'").sorted(byKeyPath: "updatedDate", ascending: false)
            }
        }
    }
    
    // MARK: - Favorite Data Model
    func bindFavoriteLibraryDataTypeModel() -> [LibraryDataTypeModel] {
        var favoriteTypes = [LibraryDataTypeModel]()
        if let model = self.libraryDataTypeModel {
            for i in 0..<model.count {
                if self.getArrayWithSection(section: i, isFavorite: true).count != 0 {
                    favoriteTypes.append(model[i])
                }
            }
        }
        return favoriteTypes
    }
    
    func getFavoriteArraySectionCount() -> Int {
        return self.bindFavoriteLibraryDataTypeModel().count
    }
    
    func getFavoriteTitleOfArrayWithSection(section: Int) -> String {
        guard let type = self.bindFavoriteLibraryDataTypeModel()[section].type else { return "" }
        return type
    }
    
    func getAllFavortieData() -> Results<LibraryDataModel> {
        let realm = try! Realm()
        return realm.objects(LibraryDataModel.self).filter("favorite = true").sorted(byKeyPath: "type")
    }
    
    func getFavoriteDataModelWithIndexPath(indexPath: IndexPath, isFavorite: Bool) -> LibraryDataModel {
        return self.getFavoriteArrayWithSection(section: indexPath.section)[indexPath.row]
    }
    
    func getFavoriteArrayCountWithSection(section: Int) -> Int {
        
        return self.getFavoriteArrayWithSection(section: section).count
    }

    func getFavoriteArrayWithSection(section: Int) -> [LibraryDataModel] {
        let realm = try! Realm()
        
        let dataType = self.bindFavoriteLibraryDataTypeModel()
        if dataType.count > 0 {
            return Array(realm.objects(LibraryDataModel.self).filter("type = '\(dataType[section].type ?? "")' AND favorite = true"))
        } else {
            return [LibraryDataModel]()
        }
        
    }
}
