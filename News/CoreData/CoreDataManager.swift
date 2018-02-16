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
            let convertedTitle = self.convertCDTitle(cdTitle)
            convertedTitles.append(convertedTitle)
        }
        return convertedTitles
    }
    
    func getNewsTitle(byId id:String) -> Title? {
        guard let cdTitle = self.findCDNewsTitle(byId: id) else {
            return nil
        }
        return self.convertCDTitle(cdTitle)
    }
    
    func convertCDTitle(_ cdTitle:CDNewsTitle) -> Title {
        return Title(id: cdTitle.id ?? "-1",
                     name: cdTitle.name ?? "empty name",
                     text: cdTitle.text ?? "empty text",
                     publicationDate: DateMS(milliseconds: cdTitle.publicationDate),
                     bankInfoTypeId: Int(cdTitle.bankInfoTypeId),
                     viewsCount: Int(cdTitle.viewsCount))
    }
    
    func increaseTitleViewsCount(byId id:String) {
        if let cdTitle = self.findCDNewsTitle(byId: id) {
            cdTitle.viewsCount = cdTitle.viewsCount + 1
            self.appDelegate.saveContext()
        } else {
            print("Could not increase views count by id=\(id).")
        }
    }
    
    func titleViewsCount(byId id:String) -> Int {
        if let cdTitle = self.findCDNewsTitle(byId: id) {
            return Int(cdTitle.viewsCount)
        }
        return 0
    }
    
    func findCDNewsTitle(byId id:String) -> CDNewsTitle? {
        var cdTitle:CDNewsTitle?
        let request = CDNewsTitle.fetchRequest() as NSFetchRequest<CDNewsTitle>
        request.predicate = NSPredicate(format: "id == %@", id)
        do {
            cdTitle = try self.context.fetch(request).first
        } catch let error as NSError {
            print("Could not fetch Title by id=\(id). \(error), \(error.userInfo)")
        }
        return cdTitle
    }
    
    func getNewsDetail(byTitleId id:String) -> NewsDetail? {
        var cdNewsItem:CDNewsItem?
        let request = CDNewsItem.fetchRequest() as NSFetchRequest<CDNewsItem>
        request.predicate = NSPredicate(format: "title.id == %@", id)
        do {
            cdNewsItem = try self.context.fetch(request).first
        } catch let error as NSError {
            print("Could not fetch Title by id=\(id). \(error), \(error.userInfo)")
        }
        guard let cdTitle = cdNewsItem?.title, let cdNews = cdNewsItem else {
            return nil
        }
        let title = self.convertCDTitle(cdTitle)
        return NewsDetail(title: title,
                          creationDate: DateMS(milliseconds:cdNews.creationDate),
                          lastModificationDate: DateMS(milliseconds:cdNews.lastModificationDate),
                          bankInfoTypeId: Int(cdNews.bankInfoTypeId),
                          typeId: cdNews.typeId ?? "no type",
                          content: cdNews.content ?? "")
    }
    
    func saveNewsDetail(_ newsDetail:NewsDetail) {
        if let cdTitle = self.findCDNewsTitle(byId: newsDetail.title.id) {
            let cdNewsItem = CDNewsItem(entity: CDNewsItem.entity(), insertInto: self.context)
            cdNewsItem.title = cdTitle
            cdNewsItem.content = newsDetail.content
            cdNewsItem.bankInfoTypeId = Int64(newsDetail.bankInfoTypeId)
            cdNewsItem.creationDate = newsDetail.creationDate.milliseconds
            cdNewsItem.lastModificationDate = newsDetail.lastModificationDate.milliseconds
            cdNewsItem.typeId = newsDetail.typeId
            self.appDelegate.saveContext()
        } else {
            print("Could not assotiate NewsItem with Title id=\(newsDetail.title.id).")
        }
    }
}
