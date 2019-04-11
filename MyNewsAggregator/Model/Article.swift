//
//  Article.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import Foundation
import RealmSwift

class Article: Object, NSCopying {
    
    @objc dynamic var sourceTitle: String = ""
    @objc dynamic var sourceImageUrl: String = ""
    @objc dynamic var articleTitle: String = ""
    @objc dynamic var articleImageUrl: String = ""
    @objc dynamic var articleUrl: String = ""
    @objc dynamic var articlePublicationTime: String = ""
    
    func copy(with zone: NSZone? = nil) -> Any {
        let article = Article()
        article.sourceTitle = self.sourceTitle
        article.sourceImageUrl = self.sourceImageUrl
        article.articleTitle = self.articleTitle
        article.articleImageUrl = self.articleImageUrl
        article.articleUrl = self.articleUrl
        article.articlePublicationTime = self.articlePublicationTime
        return article
    }
}
