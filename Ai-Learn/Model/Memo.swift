//
//  Memo.swift
//  Ai-Learn
//
//  Created by vMio on 8/21/19.
//  Copyright © 2019 VmioSystem. All rights reserved.
//

import Foundation

class Memo {
    var category_id: Int?
    var category_name: String?
    var collection_time: String?
    var content: String?
    var kml_id: Int?
    var lat: String?
    var lng: String?
    var memo_at: Double?
    var memo_at_str: String?
    var user_id: Int?
    var user_name: String?
    var imgString: String = "placeholder"
    init(category_id: Int,category_name:String,collection_time: String,content: String,kml_id: Int,lat: String,lng: String,memo_at: Double,memo_at_str: String,user_id: Int,user_name:String){
        self.category_name = category_name
        self.collection_time = collection_time
        self.content = content
        self.kml_id = kml_id
        self.lat = lat
        self.lng = lng
        self.memo_at = memo_at
        self.memo_at_str = memo_at_str
        self.user_id = user_id
        self.user_name = user_name
        self.category_id = category_id
        
        switch self.category_id {
        case 1:
            self.imgString = "Material inspection"
        case 2:
            self.imgString = "Construction confirmation"
        case 3:
            self.imgString = "Self-management"
        case 4:
            self.imgString = "Plastic"
        default:
            self.imgString = "placeholder"
        }
    }
}
