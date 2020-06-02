//
//  Category.swift
//  Ai-Learn
//
//  Created by vMio on 8/28/19.
//  Copyright © 2019 VmioSystem. All rights reserved.
//

import Foundation

class Category {
    var id: Int?
    var name: String?
    var select: Int?
    init(id: Int, name: String, select: Int) {
        self.id = id
        self.name = name
        self.select = select
    }
}
