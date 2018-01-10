//
//  Category.swift
//  TodoGe
//
//  Created by Ming jie Huang on 1/6/18.
//  Copyright © 2018 Ming jie Huang. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name : String = ""
    @objc dynamic var backgroundColor : String = ""
    let items = List<Item>()
    
}
