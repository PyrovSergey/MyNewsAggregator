//
//  Article.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

//import Foundation
import Realm
import RealmSwift
import ObjectMapper

class Article: Object, Mappable {
    
    @objc dynamic var sourceTitle: String = ""
    @objc dynamic var sourceImageUrl: String = ""
    @objc dynamic var articleTitle: String = ""
    @objc dynamic var articleImageUrl: String = ""
    @objc dynamic var articleUrl: String = ""
    @objc dynamic var articlePublicationTime: String = ""
    
    public required init(map: Map) {
        super.init()
    }
    
    required public init() {
        super.init()
    }
    
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    public override init(value: Any) {
        super.init(value: value)
    }
    
    public func mapping(map: Map) {
        sourceTitle <- map[Key.sourceTitle.rawValue]
        sourceImageUrl = Utils.getArticleImage(url: map[Key.articleUrl.rawValue].currentValue as! String)
        articleTitle <- map[Key.articleTitle.rawValue]
        articleImageUrl <- map[Key.articleImageUrl.rawValue]
        articleUrl <- map[Key.articleUrl.rawValue]
        articlePublicationTime <- map[Key.articlePublicationTime.rawValue]
    }
}

// MARK: - NSCopying
extension Article: NSCopying {
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

// MARK: - TableViewCellViewModelType
extension Article: TableViewCellViewModelType { }

// MARK: - Keys
private extension Article {
    enum Key: String {
        case sourceTitle = "source.name"
        case articleTitle = "title"
        case articleImageUrl = "urlToImage"
        case articleUrl = "url"
        case articlePublicationTime = "publishedAt"
    }
}
