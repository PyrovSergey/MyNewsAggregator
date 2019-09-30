//
//  BookmarksViewModel.swift
//  MyNewsAggregator
//
//  Created by Sergey on 30/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import RxSwift
import RxCocoa

class BookmarksViewModel: NSObject {
    
    var bookmarks: Driver<[Article]> {
        return bookmarksData.asDriver()
    }
    
    private var bookmarksData = BehaviorRelay<[Article]>(value: [])
    private let bookmarksManager = BookmarksManager()
    private let bag = DisposeBag()
    
}

// MARK: - Public Interface
extension BookmarksViewModel {
    
    func load() {
        bookmarksManager.load().subscribe(onSuccess: { [weak self] bookmarks in
            self?.bookmarksData.accept(bookmarks)
        }).disposed(by: bag)
    }
    
    func delete(at indexPath: IndexPath) {
        bookmarksManager.delete(indexPath: indexPath).subscribe(onCompleted: {
            self.load()
        }, onError: { error in
            AlertController.shared.showErrorToast(error: "Error deleting bookmark", autoHide: true)
        }).disposed(by: bag)
    }
}
