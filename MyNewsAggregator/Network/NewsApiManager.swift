//
//  NewsAPI.swift
//  MyNewsAggregator
//
//  Created by Sergey on 27/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import RxSwift
import SwiftyJSON

class NewsApiManager {
    
    private let baseUrlTopHeadlinesAndCategory: String = "https://newsapi.org/v2/top-headlines"
    private let baseUrlForRequest: String = "https://newsapi.org/v2/everything"
    private let apiKey: String = "1d48cf2bd8034be59054969db665e62e"
    private let headLines: String = "HeadLines"
    private let pageSize: String = "100"
    
    private lazy var paramsForTopHeadLinesNews: [String : String] = [
        "country" : Utils.getCurrentCountry(),
        "pageSize" : pageSize,
        "apiKey" : apiKey
    ]
    
    private lazy var paramsForSearch: [String : String] = [
        "q" : "request",
        "language" : Utils.getCurrentLanguage(),
        "sortBy" : "relevancy",
        "pageSize" : pageSize,
        "apiKey" : apiKey
    ]
}

// MARK: - Public Interface
extension NewsApiManager {
    
    func request(_ request: String? = nil) -> Single<ArticlesResponse> {
        
        paramsForSearch["q"] = headLines
        
        let params = request == nil ? paramsForTopHeadLinesNews : paramsForSearch
        let url = request == nil ? baseUrlTopHeadlinesAndCategory : baseUrlForRequest
        
        return Single.create(subscribe: { single -> Disposable in
            
            guard ConnectionManager.shared.isConnected else {
                return Disposables.create()
            }
            
            AlertController.shared.showProgress()
            
            Alamofire.request(url, method: .get, parameters: params).responseObject { (response: DataResponse<ArticlesResponse>) in
                
                switch response.result {
                case .success(let value):
                    single(.success(value))
                case .failure(let error):
                    single(.error(error))
                }
                
            }
            return Disposables.create {
                AlertController.shared.hideProgress()
            }
        })
    }
}
