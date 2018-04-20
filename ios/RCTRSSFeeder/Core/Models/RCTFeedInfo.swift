//
//  RCTFeedInfo.swift
//  RCTRSSFeeder
//
//  Created by modao on 2018/4/20.
//  Copyright © 2018年 MockingBot. All rights reserved.
//

import UIKit

class RCTFeedInfo: NSObject, NSCoding {
    
    private(set) var title: String?
    private(set) var link: String?
    private(set) var summary: String?
    private(set) var url: String?
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(link, forKey: "link")
        aCoder.encode(summary, forKey: "summary")
        aCoder.encode(url, forKey: "url")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        title = aDecoder.decodeObject(forKey: "title") as? String
        link = aDecoder.decodeObject(forKey: "link") as? String
        summary = aDecoder.decodeObject(forKey: "summary") as? String
        url = aDecoder.decodeObject(forKey: "url") as? String
    }
    
    override var description: String {
        return title ?? "RCTFeedInfo"
    }
}
