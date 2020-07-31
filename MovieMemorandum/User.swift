//
//  User.swift
//  MovieMemorandum
//
//  Created by 藤田えりか on 2019/02/12.
//  Copyright © 2019 com.erica. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var objectId: String
    var userName: String
    var displayName: String?
    var userMemo: String?
    var best1: String?
    var best2: String?
    var best3: String?
    var userimage: UIImageView?
    var userImageUrl: String?
    
    
    init(objectId: String, userName: String) {
        self.objectId = objectId
        self.userName = userName
    }
}
