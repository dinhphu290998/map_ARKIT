//
//  CompanyCode.swift
//  Ai-Learn
//
//  Created by vMio on 8/22/19.
//  Copyright © 2019 VmioSystem. All rights reserved.
//

import Foundation

class CompanyCode {
    var aisys : String?
    var code : String?
    var kms : String?
    var domain: String?
    var name : String?
    var nickname: String?
    var id: Int?
    
    init(aisys : String,code : String,kms : String,domain: String,name : String,nickname: String,id: Int) {
        self.aisys = aisys
        self.code = code
        self.kms = kms
        self.domain = domain
        self.name = name
        self.nickname = nickname
        self.id = id
    }

}
