//
//  RCTRSSParser.swift
//  RCTRSSFeeder
//
//  Created by modao on 2018/4/20.
//  Copyright © 2018年 MockingBot. All rights reserved.
//

import Foundation

@objc
protocol RCTFeedParserDelegate: NSObjectProtocol {
    @objc optional func parseDidStart(parser: RCTRSSFeedParser)
    @objc optional func parseDidParseFeedInfo(parser: RCTRSSFeedParser, info: RCTFeedInfo)
    @objc optional func parseDidParseFeedItem(parser: RCTRSSFeedParser, item: RCTFeedItem)
    @objc optional func parseDidFinishe(parser: RCTRSSFeedParser)
    @objc optional func parseDidFailWithError(parser: RCTRSSFeedParser, error: NSError)
}

public class RCTRSSFeedParser: NSObject {
    enum ConnectionType {
        case sync, async
    }
    enum ParseType {
        case Full, ItemsOnly, InfoOnly
    }
    enum FeedType {
        case Unknown, RSS, RSS1, Atom
    }

    weak var delegate: RCTFeedParserDelegate?
    private var urlSessionTask: URLSessionDataTask?
    private var asyncData: Data?
    private var asyncTextEncodingName: String?
    private var feedParser = XMLParser()
    private var request: URLRequest?
    private(set) var url: URL?
    var feedParseType = ParseType.Full
    var connectType = ConnectionType.sync
    private var feedType = FeedType.Unknown
    private(set) var isStopped = true
    private(set) var isFailed = false
    private(set) var isParsing = false
    private var isAborted = false
    private var isParsingComplete = false
    private var hasEncounteredItems = false
    private var pathOfElementWithXHTMLType = ""
    private var parseStructureAsContent = false
    private let dateFormatterRFC822 = DateFormatter()
    private let dateFormatterRFC3339 = DateFormatter()

    //Parsing Data
    private var currentPath = ""
    private var currentText = NSMutableString()
    private var currentElementAttributes = [String: Any]()
    private var item: RCTFeedItem?
    private var info: RCTFeedInfo?

    private override init() {
        super.init()
        let locale = Locale(identifier: "en_US_POSIX")
        dateFormatterRFC822.locale = locale
        dateFormatterRFC3339.locale = locale
        dateFormatterRFC822.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatterRFC3339.timeZone = TimeZone(secondsFromGMT: 0)
    }

    convenience init(feedURL: URL) {
        var req = URLRequest(url: feedURL,
                             cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                             timeoutInterval: 60)
        req.addValue("RCTFeedParser", forHTTPHeaderField: "User-Agent")
        self.init(feedRequest: req)
    }

    convenience init(feedRequest: URLRequest) {
        self.init()
        url = feedRequest.url
        request = feedRequest
    }

    func parse() -> Bool {
        return false
    }

    func stop()  {

    }

    func reset()  {
        asyncData = nil
        asyncTextEncodingName = nil
        urlSessionTask = nil
        feedType = .Unknown
    }
}
