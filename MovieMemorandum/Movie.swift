//
//  Movie.swift
//  MovieMemorandum
//
//  Created by 藤田えりか on 2019/01/09.
//  Copyright © 2019 com.erica. All rights reserved.
//

import UIKit


class Movie: NSObject {
    
    var title: String
    var imageUrl : String
    var star: Int
    var user : User
    var supervisor: String?
    var date: String?
    var review: String?
    var post: Bool!
    var objectID: String
    
   
    init(title: String,imageUrl:String, star:Int, user: User, objectID: String) {
        self.title = title
        self.imageUrl = imageUrl
        self.star = star
        self.user = user
        self.objectID = objectID
    }
    
}
