//
//  CDNewsItem+CoreDataProperties.swift
//  News
//
//  Created by Sergey Roslyakov on 2/15/18.
//  Copyright © 2018 Sergey Roslyakov. All rights reserved.
//
//

import Foundation
import CoreData


extension CDNewsItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDNewsItem> {
        return NSFetchRequest<CDNewsItem>(entityName: "CDNewsItem")
    }

    @NSManaged public var content: String?
    @NSManaged public var bankInfoTypeId: Int64
    @NSManaged public var lastModificationDate: Double
    @NSManaged public var creationDate: Double
    @NSManaged public var typeId: String?
    @NSManaged public var title: CDNewsTitle?

}
