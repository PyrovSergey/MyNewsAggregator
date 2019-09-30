//
//  CategoryViewModel.swift
//  MyNewsAggregator
//
//  Created by Sergey on 30/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import RxSwift
import RxCocoa

class CategoryViewModel {
    
    var articles: Driver<[Article]> {
        return articlesList.asDriver()
    }
    
    init(categoryName: String) {
        nameOfCategory = categoryName
    }
    
    private let nameOfCategory: String?
    private var articlesList = BehaviorRelay<[Article]>(value: [])
    private lazy var networkManager = NetworkRxManager()
    private let bag = DisposeBag()
}

// MARK: - Public Interface
extension CategoryViewModel {
    
    func updateCategoryNews() {
        guard let name = nameOfCategory else { return }
        networkManager.getDataNews(by: name).subscribe(onSuccess: { articlesResponse in
            guard let articles = articlesResponse.articles else { return }
            self.articlesList.accept(articles)
        }, onError: { error in
            print(error.localizedDescription)
        }).disposed(by: bag)
    }
}
