//
//  BookmarksManager.swift
//  MyNewsAggregator
//
//  Created by Sergey on 30/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//


import RealmSwift
import RxSwift

class BookmarksManager {
    
    private let realm = try! Realm()
    private var bookmarksArray : Results<Article>?
    
    private var bookmarks: [Article] {
        let result = self.realm.objects(Article.self)
        return Array(result)
    }
}

// MARK: - Public interface
extension BookmarksManager {
    
    func load() -> Single<[Article]> {
        
        return Single.create(subscribe: { single -> Disposable in
            single(.success(self.bookmarks))
            return Disposables.create()
        })
    }
    
    func delete(indexPath: IndexPath) -> Completable {
        
        return Completable.create(subscribe: { event -> Disposable in
            
            let bookmark = self.bookmarks[indexPath.row]
            do {
                try self.realm.write {
                    self.realm.delete(bookmark)
                    event(.completed)
                }
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        })
    }
    
    func add(article: Article) -> Completable {
        
        return Completable.create(subscribe: { event -> Disposable in
            
            do {
                try self.realm.write {
                    self.realm.add(article)
                    event(.completed)
                }
            } catch {
                event(.error(error))
            }
            return Disposables.create()
        })
    }
    
    func checkArticleInBookmarks(article: Article) -> Single<Bool> {
        
        return Single.create(subscribe: { single -> Disposable in
            
            if self.bookmarks.contains(where: {$0.articleUrl == article.articleUrl}) {
                single(.success(true))
            } else {
                single(.success(false))
            }
            return Disposables.create()
        })
    }
}
