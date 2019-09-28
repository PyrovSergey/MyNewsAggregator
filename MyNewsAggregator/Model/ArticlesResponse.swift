//
//  ArticlesResponse.swift
//  MyNewsAggregator
//
//  Created by Sergey on 27/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import ObjectMapper

struct ArticlesResponse: Mappable {
    
    var totalResults: Int!
    var articles: [Article]?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        totalResults <- map[Key.totalCount.rawValue]
        articles <- map[Key.articles.rawValue]
    }
}

// MARK: - Keys
private extension ArticlesResponse {
    enum Key: String {
        case totalCount = "totalResults"
        case articles = "articles"
    }
}
