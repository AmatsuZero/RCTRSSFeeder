//
//  String+HTML.swift
//  RCTRSSFeeder
//
//  Created by modao on 2018/4/20.
//  Copyright © 2018年 MockingBot. All rights reserved.
//

import Foundation

private let newLinesAndWhiteSpace = String(format: " \t\n\r%C%C%C%C",
                                   UniChar(0x0085),
                                   UniChar(0x000C),
                                   UniChar(0x2028),
                                   UniChar(0x2029))
private let newLinesAndWhiteSpaceCharacters = CharacterSet(charactersIn: newLinesAndWhiteSpace)

public extension NSString {

    /// Strips HTML tags & comments, removes extra whitespace and decodes HTML character entities.
    func convertHTMLToplainText() -> NSString {
        let stopValues = String(format: "< \t\n\r%C%C%C%C",
                          UniChar(0x0085),
                          UniChar(0x000C),
                          UniChar(0x2028),
                          UniChar(0x2029))

        let stopCharacters = CharacterSet(charactersIn: stopValues)
        let tagNameCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let result = NSMutableString(capacity: self.length)
        let scanner = Scanner(string: self as String)
        scanner.caseSensitive = true
        var str, tagName: NSString?
        var dontReplaceTagWithSpace = false
        let skipTags = Set(["a","b", "i", "q", "span", "em", "strong", "cite", "abbr", "acronym", "label"])
        return autoreleasepool {
            repeat {
                // Scan up to the start of a tag or whitespace
                if scanner.scanUpToCharacters(from: stopCharacters, into: &str), let stop = str as String? {
                    result.append(stop)
                    str = nil // reset
                }
                // Check if we've stopped at a tag/comment or whitespace
                if scanner.scanString("<", into: nil) {
                    // Stopped at a comment, script tag, or other tag
                    if scanner.scanString("!--", into: nil) {
                        // Comment
                        scanner.scanUpTo("-->", into: nil)
                        scanner.scanString("-->", into: nil)
                    } else if scanner.scanString("script", into: nil) {
                        // Script tag where things don't need escaping!
                        scanner.scanUpTo("</script>", into: nil)
                        scanner.scanString("</script>" , into: nil)
                    } else {
                        // Tag - remove and replace with space unless it's
                        // a closing inline tag then dont replace with a space
                        if scanner.scanString("/", into: nil) {
                            // Closing tag - replace with space unless it's inline
                            tagName = nil
                            dontReplaceTagWithSpace = false
                            if scanner.scanCharacters(from: tagNameCharacters, into: &tagName), let tag = tagName as String? {
                                dontReplaceTagWithSpace = skipTags.contains(tag.lowercased())
                            }
                            // Replace tag with string unless it was an inline
                            if !dontReplaceTagWithSpace, result.length > 0, !scanner.isAtEnd {
                                result.append(" ")
                            }
                        }
                        // Scan past tag
                        scanner.scanUpTo(">", into: nil)
                        scanner.scanString(">", into: nil)
                    }
                } else {
                    // Stopped at whitespace - replace all whitespace and newlines with a space
                    if scanner.scanCharacters(from: newLinesAndWhiteSpaceCharacters, into: nil),
                        result.length > 0,
                        !scanner.isAtEnd {
                        result.append(" ")
                    }
                }
            } while !scanner.isAtEnd
            // Cleanup
            // Decode HTML entities and return
            return result.decodeHTMLEntities()
        }
    }

    /// Decode all HTML entities using GTM.
    func decodeHTMLEntities() -> NSString {
        return NSString(string: self.gtm_stringByUnescapingFromHTML())
    }

    /// Minimal unicode encoding will only cover characters from table
    func encodeHTMLEntities(isUnicde: Bool = false) -> NSString {
        return NSString(string: isUnicde ? self.gtm_stringByUnescapingFromHTML() : self.gtm_stringByEscapingForAsciiHTML())
    }

    /// Replace newlines with <br /> tags.
    func withNewLinesAsBrs() -> NSString {
        // Strange New lines:
        //    Next Line, U+0085
        //    Form Feed, U+000C
        //    Line Separator, U+2028
        //    Paragraph Separator, U+2029
        // Scanner
        let scanner = Scanner(string: self as String)
        let result = NSMutableString()
        var temp: NSString?
        return autoreleasepool {
            // scan
            repeat {
                // Get non new line or whitespace characters
                temp = nil
                scanner.scanCharacters(from: newLinesAndWhiteSpaceCharacters, into: &temp)
                if let str = temp as String? {
                    result.append(str)
                }
                temp = nil
                // Add <br /> s
                if scanner.scanString("\r\n", into: nil) {
                    // Combine \r\n into just 1 <br />
                    result.append("<br />")
                } else if scanner.scanCharacters(from: newLinesAndWhiteSpaceCharacters, into: &temp), let str = temp as String? {
                    for _ in 0..<str.count {
                        result.append("<br />")
                    }
                }
            } while !scanner.isAtEnd
            return NSString(string: result)
        }
    }

    /// Remove newlines and white space from string.
    func removingNewLinesAndWhitespace() -> NSString {
        let scanner = Scanner(string: self as String)
        let result = NSMutableString()
        var temp: NSString?
        return autoreleasepool {
            // Strange New lines:
            //    Next Line, U+0085
            //    Form Feed, U+000C
            //    Line Separator, U+2028
            //    Paragraph Separator, U+2029
            // scan
            while !scanner.isAtEnd {
                // Get non new line or whitespace characters
                temp = nil
                scanner.scanCharacters(from: newLinesAndWhiteSpaceCharacters, into: &temp)
                if let str = temp as String? {
                    result.append(str)
                }
                // Replace with a space
                if scanner.scanCharacters(from: newLinesAndWhiteSpaceCharacters, into: nil),
                    result.length > 0,
                    !scanner.isAtEnd { // Dont append space to beginning or end of result
                    result.append(" ")
                }
            }
            return NSString(string: result)
        }
    }

    /// Wrap plain URLs in <a href="..." class="linkified">...</a>
    //  - Ignores URLs inside tags (any URL beginning with =")
    //  - HTTP & HTTPS schemes only
    //  - Only works in iOS 4+ as we use NSRegularExpression (returns self if not supported so be careful with NSMutableStrings)
    //  - Expression: (?<!=")\b((http|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?)
    //  - Adapted from http://regexlib.com/REDetails.aspx?regexp_id=96
    func linkifyingURLs() -> NSString {
        let pattern = "(?<!=\")\\b((http|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%%&amp;:/~\\+#]*[\\w\\-\\@?^=%%&amp;/~\\+#])?)"
        let regex = try! NSRegularExpression(pattern: pattern, options: .init(rawValue: 0))
        return autoreleasepool {
            return regex.stringByReplacingMatches(in: self as String,
                                                  options: .init(rawValue: 0),
                                                  range: NSRange(location: 0, length: self.length),
                                                  withTemplate: "<a href=\"$1\" class=\"linkified\">$1</a>") as NSString
        }
    }
}
