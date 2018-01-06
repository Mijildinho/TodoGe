//
//  Item.swift
//  TodoGe
//
//  Created by Ming jie Huang on 1/6/18.
//  Copyright © 2018 Ming jie Huang. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?

    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
