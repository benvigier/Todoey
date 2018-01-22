//
//  ToDoItem.swift
//  Todoey
//
//  Created by Benjamin Vigier on 1/22/18.
//  Copyright © 2018 Benjamin Vigier. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoItem: Object{
    @objc dynamic var label = ""
    @objc dynamic var isSelected : Bool = false
    @objc dynamic var dateCreated = Date()
    var category = LinkingObjects(fromType: Category.self, property: "items")
}
