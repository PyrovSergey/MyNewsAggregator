//
//  Utils.swift
//  MyNewsAggregator
//
//  Created by Sergey on 27/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import Foundation

class Utils {
    
    static func getCurrentCountry() -> String {
        print("LANGUAGE ------->>>> \(Locale.preferredLanguages[0].lowercased().dropLast(3))")
        var defaultCountry: String = "us"
        let arrayCountry = Storage.shared.getCountries()
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            if arrayCountry.contains(countryCode.lowercased()) {
                defaultCountry = countryCode.lowercased()
            }
        }
        print("COUNTRY  ------->>>> \(defaultCountry)")
        return defaultCountry
    }
    
    static func getCurrentLanguage() -> String {
        return String(Locale.preferredLanguages[0].lowercased().dropLast(3))
    }
    
    static func getDateFromApi(date: String) -> Date {
        var parsingString = date
        parsingString.removeLast()
        let parsingDateAndTime = parsingString.components(separatedBy: "T")
        let parsingDate = parsingDateAndTime[0]
        let parsingTime = parsingDateAndTime[1]
        let date = parsingDate.components(separatedBy: "-")
        let time = parsingTime.components(separatedBy: ":")
        let year = date[0]
        let mounth = date[1]
        let day = date[2]
        let hours = time[0]
        let min = time[1]
        let sec = time[2]
        var components = DateComponents()
        components.day = Int(day)!
        components.month = Int(mounth)!
        components.year = Int(year)!
        components.hour = Int(hours)!
        components.minute = Int(min)!
        components.second = Int(sec)!
        components.timeZone = TimeZone(abbreviation: "UTC")
        let datePublishedAt = Calendar.current.date(from: components as DateComponents)
        return datePublishedAt!
    }
}
