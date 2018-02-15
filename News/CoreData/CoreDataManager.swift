//
//  CDEntitiesTransformer.swift
//  News
//
//  Created by Sergey Roslyakov on 2/15/18.
//  Copyright © 2018 Sergey Roslyakov. All rights reserved.
//

import UIKit
import CoreData


class CoreDataManager {
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static let shared = CoreDataManager()
    
    func saveNewsTitles(_ titles:[Title]) {
        for title in titles {
            if self.getNewsTitle(byId: title.id) == nil {
                let cdTitle = CDNewsTitle(entity: CDNewsTitle.entity(), insertInto: self.context)
                cdTitle.id = title.id
                cdTitle.name = title.name
                cdTitle.text = title.text
                cdTitle.publicationDate = title.publicationDate.milliseconds
                cdTitle.bankInfoTypeId = Int64(title.bankInfoTypeId)
                self.appDelegate.saveContext()
            }            
        }
    }
    
    func getAllNewsTitles() -> [Title] {
        var titles = [CDNewsTitle]()
        do {
            titles = try self.context.fetch(CDNewsTitle.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch Titles. \(error), \(error.userInfo)")
        }
        var convertedTitles = [Title]()
        for cdTitle in titles {
            let convertedTitle = Title(id: cdTitle.id ?? "-1",
                                       name: cdTitle.name ?? "empty name",
                                       text: cdTitle.text ?? "empty text",
                                       publicationDate: DateMS(milliseconds: cdTitle.publicationDate),
                                       bankInfoTypeId: Int(cdTitle.bankInfoTypeId),
                                       viewsCount: Int(cdTitle.viewsCount))
            convertedTitles.append(convertedTitle)
        }
        return convertedTitles
    }
    
    func getNewsTitle(byId id:String) -> Title? {
        let request = CDNewsTitle.fetchRequest() as NSFetchRequest<CDNewsTitle>
        request.predicate = NSPredicate(format: "id == %@", id)
        var title:Title?
        var cdTitle:CDNewsTitle?
        do {
            cdTitle = try self.context.fetch(request).first
        } catch let error as NSError {
            print("Could not fetch Title by id=\(id). \(error), \(error.userInfo)")
        }
        guard let cdTitle1 = cdTitle else {
            return nil
        }
        title = Title(id: cdTitle1.id ?? "-1",
                      name: cdTitle1.name ?? "empty name",
                      text: cdTitle1.text ?? "empty text",
                      publicationDate: DateMS(milliseconds: cdTitle1.publicationDate),
                      bankInfoTypeId: Int(cdTitle1.bankInfoTypeId),
                      viewsCount: Int(cdTitle1.viewsCount))
        return title
    }
    
    func increaseTitleViewsCount(byId id:String) {
        let request = CDNewsTitle.fetchRequest() as NSFetchRequest<CDNewsTitle>
        request.predicate = NSPredicate(format: "id == %@", id)
        var cdTitle:CDNewsTitle?
        do {
            cdTitle = try self.context.fetch(request).first
        } catch let error as NSError {
            print("Could not fetch Title by id=\(id). \(error), \(error.userInfo)")
        }
        if let cdTitle = cdTitle {
            cdTitle.viewsCount = cdTitle.viewsCount + 1
            self.appDelegate.saveContext()
        }
    }
    
    func titleViewsCount(byId id:String) -> Int {
        let request = CDNewsTitle.fetchRequest() as NSFetchRequest<CDNewsTitle>
        request.predicate = NSPredicate(format: "id == %@", id)
        var cdTitle:CDNewsTitle?
        do {
            cdTitle = try self.context.fetch(request).first
        } catch let error as NSError {
            print("Could not fetch Title by id=\(id). \(error), \(error.userInfo)")
        }
        if let cdTitle = cdTitle {
            return Int(cdTitle.viewsCount)
        }
        return 0
    }
}
