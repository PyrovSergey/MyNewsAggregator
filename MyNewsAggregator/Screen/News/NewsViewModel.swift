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
    private lazy var networkManager = NetworkManager()
    private let bag = DisposeBag()
}

// MARK: - Public Interface
extension NewsViewModel {
    
    func loadNews() {
        networkManager.getTopHeadLinesNews().subscribe(onSuccess: { articlesResponse in
            guard let articles = articlesResponse.articles else { return }
            self.articlesList.accept(articles)
        }, onError: { error in
            print(error.localizedDescription)
        }).disposed(by: bag)
    }
    
    func searchNews() {
        guard searchText.value.isEmpty == false else { return }
        networkManager.getDataNews(by: searchText.value).subscribe(onSuccess: { articlesResponse in
            guard let articles = articlesResponse.articles else { return }
            self.articlesList.accept(articles)
        }, onError: { error in
            print(error.localizedDescription)
        }).disposed(by: bag)
    }
}

