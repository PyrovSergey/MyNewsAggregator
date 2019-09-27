//
//  NetworkManager.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import Alamofire
import SwiftyJSON
import DateToolsSwift
import PromiseKit


class NetworkManager {
    
    static let shared = NetworkManager()
    
    private lazy var swipeCategory = Storage.shared.getCategories()
    private let baseUrlTopHeadlinesAndCategory: String = "https://newsapi.org/v2/top-headlines"
    private let baseUrlForRequest: String = "https://newsapi.org/v2/everything"
    private let apiKey: String = "1d48cf2bd8034be59054969db665e62e"
    private let pageSize: String = "100"
    
    private var temporaryStorage: Storage
    
    private init() {
        temporaryStorage = Storage.shared
    }
}

// MARK: - Network Request
extension NetworkManager {
    
    func getTopHeadLinesNews(listener: NetworkProtocol) {
        let params: [String : String] = [
            "country" : Utils.getCurrentCountry(),
            "pageSize" : pageSize,
            "apiKey" : apiKey
        ]
        getRequest(params, listener, "HeadLines")
    }
    
    func getRequestDataNews(request: String, listener: NetworkProtocol) {
        let params: [String : String] = [
            "q" : request,
            "sortBy" : "relevancy",
            "pageSize" : pageSize,
            "apiKey" : apiKey
        ]
        getRequest(params, listener, request)
    }
    
    func getUpdateCategoryLists(listener: NetworkProtocol) {
        for category in swipeCategory {
            let params: [String : String] = [
                "q" : category,
                "language" : Utils.getCurrentLanguage(),
                "sortBy" : "relevancy",
                "pageSize" : pageSize,
                "apiKey" : apiKey
            ]
            getRequest(params, listener, category)
        }
    }
}

// MARK: - Private
private extension NetworkManager {
    
    func getRequest(_ params: [String : String], _ listener: NetworkProtocol, _ category: String) {
        var url: String?
        if params.count == 3  {
            url = baseUrlTopHeadlinesAndCategory
        } else {
            url = baseUrlForRequest
        }
        Alamofire.request(url!, method: .get, parameters: params).responseJSON {
            response in
            if response.result.isSuccess {
                let responseJSON : JSON = JSON(response.result.value!)
                self.parsingJsonResult(responseJSON, listener, category)
            } else {
                listener.errorRequest(errorMessage: "Response in errorr \(response.error!)")
            }
        }
    }
    
    func parsingJsonResult(_ responseJSON: JSON, _ listener: NetworkProtocol, _ category: String) {
        var resultArrayArticles = [Article]()
        if let responseArticleArray = responseJSON["articles"].array {
            if !responseArticleArray.isEmpty {
                for responseArticle in responseArticleArray {
                    let article = Article()
                    
                    article.sourceTitle = responseArticle["source"]["name"].string ?? ""
                    article.articleTitle = responseArticle["title"].string ?? ""
                    article.articleImageUrl = responseArticle["urlToImage"].string ?? ""
                    article.articleUrl = responseArticle["url"].string ?? "none"
                    
                    let publishedAtString = responseArticle["publishedAt"].string ?? ""
                    
                    article.articlePublicationTime = Utils.getDateFromApi(date: publishedAtString).timeAgoSinceNow
                    
                    
                    if let newsUrl: URL = URL(string: article.articleUrl) {
                        let baseSourceUrl = newsUrl.host
                        article.sourceImageUrl = "https://besticon-demo.herokuapp.com/icon?url=\(baseSourceUrl!)&size=32..64..64"
                    }
                    resultArrayArticles.append(article)
                }
            }
        }
        Storage.shared.setCategoryList(result: resultArrayArticles, categoryName: category)
        listener.successRequest(result: resultArrayArticles, category: category)
    }
}

