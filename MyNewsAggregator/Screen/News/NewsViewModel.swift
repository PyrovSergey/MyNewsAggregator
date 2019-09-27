//
//  NewsViewModel.swift
//  MyNewsAggregator
//
//  Created by Sergey on 27/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import RxSwift
import RxCocoa

class NewsViewModel: NSObject {
    
    let searchText = BehaviorRelay<String>(value: "")
    
    var articles: Driver<[Article]> {
        return articlesList.asDriver()
    }
    
    private var articlesList = BehaviorRelay<[Article]>(value: [])
    private lazy var networkManager = NetworkRxManager()
    private let bag = DisposeBag()
}

// MARK: - Public Interface
extension NewsViewModel {
    
    func loadNews() {
        networkManager.getTopHeadLinesNews().subscribe(onSuccess: { response in
            guard let listOfArticles = response.articles else { return }
            self.articlesList.accept(listOfArticles)
        }, onError: { error in
            print(error.localizedDescription)
        }).disposed(by: bag)
    }
    
    func searchNews(by request: String) {
        networkManager.getDataNews(by: request).subscribe(onSuccess: { response in
            guard let listOfArticles = response.articles else { return }
            self.articlesList.accept(listOfArticles)
        }, onError: { error in
            print(error.localizedDescription)
        }).disposed(by: bag)
    }
}

