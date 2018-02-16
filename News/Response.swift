//
//  Response.swift
//  News
//
//  Created by Sergey Roslyakov on 2/14/18.
//  Copyright © 2018 Sergey Roslyakov. All rights reserved.
//

import UIKit

struct ResponseNews:Decodable {
    var resultCode:String
    var trackingId:String
    var payload:[Title]
}

struct ResponseDetailNews:Decodable {
    var resultCode:String
    var trackingId:String
    var payload:NewsDetail
}

struct NewsDetail:Decodable {
    var title:Title
    var creationDate:DateMS
    var lastModificationDate:DateMS
    var bankInfoTypeId:Int
    var typeId:String
    var content:String
}

struct Title:Decodable {
    var id:String
    var name:String
    var text:String
    var publicationDate:DateMS
    var bankInfoTypeId:Int
    var viewsCount:Int?
}

struct DateMS:Decodable {
    var milliseconds:Double
}
