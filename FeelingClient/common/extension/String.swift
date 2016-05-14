//
//  String.swift
//  ExSwift
//
//  Created by pNre on 03/06/14.
//  Copyright (c) 2014 pNre. All rights reserved.
//

import Foundation

public extension String {
    
    /**
     String length
     */
    var length: Int { return self.characters.count }
    
    /**
     self.capitalizedString shorthand
     */
    var capitalized: String { return capitalizedString }
    
    /**
     Returns the substring in the given range
     
     - parameter range:
     - returns: Substring in range
     */
    subscript (range: Range<Int>) -> String? {
        if range.startIndex < 0 || range.endIndex > self.length {
            return nil
        }
        
        let range = startIndex.advancedBy(range.startIndex) ..< startIndex.advancedBy(range.endIndex)
        
        return self[range]
    }

    

    /**
     Returns an array of strings, each of which is a substring of self formed by splitting it on separator.
     
     - parameter separator: Character used to split the string
     - returns: Array of substrings
     */
    func explode (separator: Character) -> [String] {
        return self.characters.split(isSeparator: { (element: Character) -> Bool in
            return element == separator
        }).map { String($0) }
    }
    
    /**
     Finds any match in self for pattern.
     
     - parameter pattern: Pattern to match
     - parameter ignoreCase: true for case insensitive matching
     - returns: Matches found (as [NSTextCheckingResult])
     */
    func matches (pattern: String, ignoreCase: Bool = false) -> [NSTextCheckingResult]? {
        
        if let regex = ExSwift.regex(pattern, ignoreCase: ignoreCase) {
            //  Using map to prevent a possible bug in the compiler
            return regex.matchesInString(self, options: [], range: NSMakeRange(0, length)).map { $0 }
        }
        
        return nil
    }
    
    /**
     Check is string with this pattern included in string
     
     - parameter pattern: Pattern to match
     - parameter ignoreCase: true for case insensitive matching
     - returns: true if contains match, otherwise false
     */
    func containsMatch (pattern: String, ignoreCase: Bool = false) -> Bool? {
        if let regex = ExSwift.regex(pattern, ignoreCase: ignoreCase) {
            let range = NSMakeRange(0, self.characters.count)
            return regex.firstMatchInString(self, options: [], range: range) != nil
        }
        
        return nil
    }
    
    /**
     Replace all pattern matches with another string
     
     - parameter pattern: Pattern to match
     - parameter replacementString: string to replace matches
     - parameter ignoreCase: true for case insensitive matching
     - returns: true if contains match, otherwise false
     */
    func replaceMatches (pattern: String, withString replacementString: String, ignoreCase: Bool = false) -> String? {
        if let regex = ExSwift.regex(pattern, ignoreCase: ignoreCase) {
            let range = NSMakeRange(0, self.characters.count)
            return regex.stringByReplacingMatchesInString(self, options: [], range: range, withTemplate: replacementString)
        }
        
        return nil
    }
    
    /**
     Inserts a substring at the given index in self.
     
     - parameter index: Where the new string is inserted
     - parameter string: String to insert
     - returns: String formed from self inserting string at index
     */
    func insert (index: Int, _ string: String) -> String {
        //  Edge cases, prepend and append
        if index > length {
            return self + string
        } else if index < 0 {
            return string + self
        }
        
        return self[0..<index]! + string + self[index..<length]!
    }
    
    /**
     Strips the specified characters from the beginning of self.
     
     - returns: Stripped string
     */
    func trimmedLeft (characterSet set: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String {
        if let range = rangeOfCharacterFromSet(set.invertedSet) {
            return self[range.startIndex..<endIndex]
        }
        
        return ""
    }
    
    @available(*, unavailable, message="use 'trimmedLeft' instead") func ltrimmed (set: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String {
        return trimmedLeft(characterSet: set)
    }
    
    /**
     Strips the specified characters from the end of self.
     
     - returns: Stripped string
     */
    func trimmedRight (characterSet set: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String {
        if let range = rangeOfCharacterFromSet(set.invertedSet, options: NSStringCompareOptions.BackwardsSearch) {
            return self[startIndex..<range.endIndex]
        }
        
        return ""
    }
    
    @available(*, unavailable, message="use 'trimmedRight' instead") func rtrimmed (set: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String {
        return trimmedRight(characterSet: set)
    }
    
    /**
     Strips whitespaces from both the beginning and the end of self.
     
     - returns: Stripped string
     */
    func trimmed () -> String {
        return trimmedLeft().trimmedRight()
    }
    

    
    /**
     Parses a string containing a double numerical value into an optional double if the string is a well formed number.
     
     - returns: A double parsed from the string or nil if it cannot be parsed.
     */
    func toDouble() -> Double? {
        
        let scanner = NSScanner(string: self)
        var double: Double = 0
        
        if scanner.scanDouble(&double) {
            return double
        }
        
        return nil
        
    }
    
    /**
     Parses a string containing a float numerical value into an optional float if the string is a well formed number.
     
     - returns: A float parsed from the string or nil if it cannot be parsed.
     */
    func toFloat() -> Float? {
        
        let scanner = NSScanner(string: self)
        var float: Float = 0
        
        if scanner.scanFloat(&float) {
            return float
        }
        
        return nil
        
    }
    
    /**
     Parses a string containing a non-negative integer value into an optional UInt if the string is a well formed number.
     
     - returns: A UInt parsed from the string or nil if it cannot be parsed.
     */
    func toUInt() -> UInt? {
        if let val = Int(self.trimmed()) {
            if val < 0 {
                return nil
            }
            return UInt(val)
        }
        
        return nil
    }
    
    
    /**
     Parses a string containing a boolean value (true or false) into an optional Bool if the string is a well formed.
     
     - returns: A Bool parsed from the string or nil if it cannot be parsed as a boolean.
     */
    func toBool() -> Bool? {
        let text = self.trimmed().lowercaseString
        if text == "true" || text == "false" || text == "yes" || text == "no" {
            return (text as NSString).boolValue
        }
        
        return nil
    }
    
    /**
     Parses a string containing a date into an optional NSDate if the string is a well formed.
     The default format is yyyy-MM-dd, but can be overriden.
     
     - returns: A NSDate parsed from the string or nil if it cannot be parsed as a date.
     */
    func toDate(format : String? = "yyyy-MM-dd") -> NSDate? {
        let text = self.trimmed().lowercaseString
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        if let fmt = format {
            dateFmt.dateFormat = fmt
        }
        return dateFmt.dateFromString(text)
    }
    
    /**
     Parses a string containing a date and time into an optional NSDate if the string is a well formed.
     The default format is yyyy-MM-dd hh-mm-ss, but can be overriden.
     
     - returns: A NSDate parsed from the string or nil if it cannot be parsed as a date.
     */
    func toDateTime(format : String? = "yyyy-MM-dd hh-mm-ss") -> NSDate? {
        return toDate(format)
    }
    
    
    
}

/**
 Repeats the string first n times
 */
public func * (first: String, n: Int) -> String {
    
    var result = String()
    
    n.times {
        result += first
    }
    
    return result
    
}

//  Pattern matching using a regular expression
public func =~ (string: String, pattern: String) -> Bool {
    
    let regex = ExSwift.regex(pattern, ignoreCase: false)!
    let matches = regex.numberOfMatchesInString(string, options: [], range: NSMakeRange(0, string.length))
    
    return matches > 0
    
}

//  Pattern matching using a regular expression
public func =~ (string: String, regex: NSRegularExpression) -> Bool {
    
    let matches = regex.numberOfMatchesInString(string, options: [], range: NSMakeRange(0, string.length))
    
    return matches > 0
    
}

//  This version also allowes to specify case sentitivity
public func =~ (string: String, options: (pattern: String, ignoreCase: Bool)) -> Bool {
    
    if let matches = ExSwift.regex(options.pattern, ignoreCase: options.ignoreCase)?.numberOfMatchesInString(string, options: [], range: NSMakeRange(0, string.length)) {
        return matches > 0
    }
    
    return false
    
}



extension String {
    
    func contationChinese() -> Bool {
        for char in utf16 {
            if (char > 0x4e00 && char < 0x9fff) {
                return true
            }
        }
        return false
    }
}
extension NSDate {
    var formatted:String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.stringFromDate(self)
    }
    func formattedWith(format:String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}

extension String {
    var asDate:NSDate! {
        let styler = NSDateFormatter()
        styler.dateFormat = "yyyy-MM-dd"
        return styler.dateFromString(self)!
    }
    func asDateFormattedWith(format:String) -> NSDate! {
        let styler = NSDateFormatter()
        styler.dateFormat = format
        return styler.dateFromString(self)!
    }
    
}
extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: nil, comment: "")
    }
}
