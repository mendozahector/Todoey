//
//  Category.swift
//  Todoey
//
//  Created by Hector Mendoza on 9/12/18.
//  Copyright © 2018 Hector Mendoza. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
