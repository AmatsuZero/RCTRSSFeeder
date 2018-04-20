//
//  RCTFeedItem.swift
//  RCTRSSFeeder
//
//  Created by modao on 2018/4/20.
//  Copyright © 2018年 MockingBot. All rights reserved.
//

import UIKit

class RCTFeedItem: NSObject, NSCoding {
    private(set) var identifier: String?
    private(set) var title: String?
    private(set) var link: String?
    private(set) var date: String?
    private(set) var updated: String?
    private(set) var content: String?
    private(set) var author: String?
    private(set) var summary: String?
    private(set) var enclosures: [String]?

    func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: "identifier")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(link, forKey: "link")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(updated, forKey: "updated")
        aCoder.encode(summary, forKey: "summary")
        aCoder.encode(content, forKey: "content")
        aCoder.encode(author, forKey: "author")
        aCoder.encode(enclosures, forKey: "enclosures")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        identifier = aDecoder.decodeObject(forKey: "identifier") as? String
        title = aDecoder.decodeObject(forKey: "title") as? String
        link = aDecoder.decodeObject(forKey: "link") as? String
        date = aDecoder.decodeObject(forKey: "date") as? String
        updated = aDecoder.decodeObject(forKey: "updated") as? String
        summary = aDecoder.decodeObject(forKey: "summary") as? String
        content = aDecoder.decodeObject(forKey: "content") as? String
        author = aDecoder.decodeObject(forKey: "author") as? String
        enclosures = aDecoder.decodeObject(forKey: "enclosures") as? [String]
    }
}
