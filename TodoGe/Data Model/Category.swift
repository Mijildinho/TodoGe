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
    let items = List<Item>()
    
}
