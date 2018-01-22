//
//  Category.swift
//  Todoey
//
//  Created by Benjamin Vigier on 1/22/18.
//  Copyright © 2018 Benjamin Vigier. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name = ""
    let items = List<ToDoItem>()
}
