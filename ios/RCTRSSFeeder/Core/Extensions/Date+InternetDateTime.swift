//
//  Date+InternetDateTime.swift
//  RCTRSSFeeder
//
//  Created by modao on 2018/4/20.
//  Copyright © 2018年 MockingBot. All rights reserved.
//

import Foundation

public extension Date {
    enum DateFormatHint {
        case NONE, RFC822, RFC3339
    }

    private static let internalDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    static func fromInternetDateTimeString(dateString: String, formatHint: DateFormatHint) -> Date? {
        switch formatHint {
        case .RFC3339: return fromRFC3339(dateString: dateString)
        case .RFC822: return fromRFC822(dateString: dateString)
        default: return nil
        }
    }

    private static func fromRFC822(dateString: String) -> Date? {
        let RFC822String  = dateString.uppercased()
        if RFC822String.contains(",") {
            Date.internalDateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
            if let date = Date.internalDateFormatter.date(from: RFC822String) {
                return date // Sun, 19 May 2002 15:21:36 GMT
            }
            Date.internalDateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm zzz"
            if let date = Date.internalDateFormatter.date(from: RFC822String) {
                return date // Sun, 19 May 2002 15:21 GMT
            }
            Date.internalDateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss"
            if let date = Date.internalDateFormatter.date(from: RFC822String) {
                return date // Sun, 19 May 2002 15:21:36
            }
            Date.internalDateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm"
            if let date = Date.internalDateFormatter.date(from: RFC822String) {
                return date // Sun, 19 May 2002 15:21
            }
        } else {
            Date.internalDateFormatter.dateFormat = "d MMM yyyy HH:mm:ss zzz"
            if let date = Date.internalDateFormatter.date(from: RFC822String) {
                return date // Sun, 19 May 2002 15:21:36 GMT
            }
            Date.internalDateFormatter.dateFormat = "d MMM yyyy HH:mm zzz"
            if let date = Date.internalDateFormatter.date(from: RFC822String) {
                return date // Sun, 19 May 2002 15:21 GMT
            }
            Date.internalDateFormatter.dateFormat = "d MMM yyyy HH:mm:ss"
            if let date = Date.internalDateFormatter.date(from: RFC822String) {
                return date // Sun, 19 May 2002 15:21:36
            }
            Date.internalDateFormatter.dateFormat = "d MMM yyyy HH:mm"
            if let date = Date.internalDateFormatter.date(from: RFC822String) {
                return date // Sun, 19 May 2002 15:21
            }
        }
        return nil
    }

    private static func fromRFC3339(dateString: String) -> Date? {
        var RFC3339String  = dateString.uppercased().replacingOccurrences(of: "Z", with: "-0000")
        // Remove colon in timezone as it breaks NSDateFormatter in iOS 4+.
        // - see https://devforums.apple.com/thread/45837
        if RFC3339String.count > 20 {
            RFC3339String = (RFC3339String as NSString).replacingOccurrences(of: ":",
                                                                             with: "",
                                                                             options: .init(rawValue: 0),
                                                                             range: NSRange(location: 20, length: RFC3339String.count-20))
        }
        Date.internalDateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
        if let date = Date.internalDateFormatter.date(from: RFC3339String) {
            return date // 1996-12-19T16:39:57-0800
        }
        Date.internalDateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"
        if let date = Date.internalDateFormatter.date(from: RFC3339String) {
            return date // 1937-01-01T12:00:27.87+0020
        }
        Date.internalDateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        if let date = Date.internalDateFormatter.date(from: RFC3339String) {
            return date // 1937-01-01T12:00:27
        }
        return nil
    }
}
