//
//  Errors.swift
//  RCTRSSFeeder
//
//  Created by modao on 2018/4/20.
//  Copyright © 2018年 MockingBot. All rights reserved.
//

import Foundation

public enum FeedParseError: Int, Error, CustomNSError {
    public var errorCode: Int {
        return self.rawValue
    }
    public var errorUserInfo: [String : Any] {
        switch self {
        case .NotInitiated: return [NSLocalizedDescriptionKey: "RCTRSSFeedParser not initialised correctly"]
        case .ConnectionFailed: return [NSLocalizedDescriptionKey: "Connection to the URL failed"]
        case .FeedParsingError: return [NSLocalizedDescriptionKey: "NSXMLParser encountered a parsing error"]
        case .FeedValidationError: return [NSLocalizedDescriptionKey: "NSXMLParser encountered a validation error"]
        default: return [NSLocalizedDescriptionKey: "RCTRSSFeedParser general error"]
        }
    }
    public static var errorDomain: String { return "RCTRSSFeedParser" }
    case NotInitiated = 1, ConnectionFailed, FeedParsingError, FeedValidationError, General
}
