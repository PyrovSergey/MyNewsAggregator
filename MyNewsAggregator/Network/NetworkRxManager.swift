//
//  NetworkRxManager.swift
//  MyNewsAggregator
//
//  Created by Sergey on 27/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import RxSwift

class NetworkRxManager {
    private let newsApiManager = NewsApiManager()
    private let bag = DisposeBag()
}

// MARK: - Public Interface
extension NetworkRxManager {
    
    func getTopHeadLinesNews() -> Single<ArticlesResponse> {
        
        return Single.create(subscribe: { single -> Disposable in
            
            self.newsApiManager.request().subscribe(onSuccess: { articlesResponse in
                single(.success(articlesResponse))
            }, onError: { error in
                single(.error(error))
            }).disposed(by: self.bag)
            
            return Disposables.create()
        })
    }
    
    func getDataNews(by request: String) -> Single<ArticlesResponse> {
        
        return Single.create(subscribe: { single -> Disposable in
            
            self.newsApiManager.request(request).subscribe(onSuccess: { articlesResponse in
                single(.success(articlesResponse))
            }, onError: { error in
                single(.error(error))
            }).disposed(by: self.bag)
            
            return Disposables.create()
        })
    }
}
