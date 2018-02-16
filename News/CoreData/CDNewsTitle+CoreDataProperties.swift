//
//  CDNewsTitle+CoreDataProperties.swift
//  News
//
//  Created by Sergey Roslyakov on 2/15/18.
//  Copyright © 2018 Sergey Roslyakov. All rights reserved.
//
//

import Foundation
import CoreData


extension CDNewsTitle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDNewsTitle> {
        return NSFetchRequest<CDNewsTitle>(entityName: "CDNewsTitle")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var text: String?
    @NSManaged public var publicationDate: Double
    @NSManaged public var bankInfoTypeId: Int64
    @NSManaged public var viewsCount: Int64
    @NSManaged public var newsItem: CDNewsItem?

}
