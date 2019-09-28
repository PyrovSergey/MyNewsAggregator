//
//  Utils.swift
//  MyNewsAggregator
//
//  Created by Sergey on 27/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import SwiftyJSON

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
    
    static func parsingJsonResult(_ responseJSON: JSON) -> [Article] {
        var resultArrayArticles: [Article] = []
        if let responseArticleArray = responseJSON["articles"].array {
            if !responseArticleArray.isEmpty {
                for responseArticle in responseArticleArray {
                    let article = Article()
                    
                    article.sourceTitle = responseArticle["source"]["name"].string ?? ""
                    article.articleTitle = responseArticle["title"].string ?? ""
                    article.articleImageUrl = responseArticle["urlToImage"].string ?? ""
                    article.articleUrl = responseArticle["url"].string ?? "none"
                    article.articlePublicationTime = responseArticle["publishedAt"].string ?? ""
                    
                    if let newsUrl: URL = URL(string: article.articleUrl) {
                        let baseSourceUrl = newsUrl.host
                        article.sourceImageUrl = "https://besticon-demo.herokuapp.com/icon?url=\(baseSourceUrl!)&size=32..64..64"
                    }
                    resultArrayArticles.append(article)
                }
            }
        }
        print(resultArrayArticles.count)
        return resultArrayArticles
    }
    
    static func getArticleImage(url: String) -> String {
        let baseSourceUrl: URL = URL(string: url)!
        let baseURL = baseSourceUrl.host
        let result = "https://besticon-demo.herokuapp.com/icon?url=\(baseURL!)&size=32..64..64"
        return result
    }
}
