//
//  ArticleViewController.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift

class ArticleViewController: UIViewController {
    
    var article: Article?

    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!

    private let realm = try! Realm()
    private var bookmarksArray : Results<Article>?
    private var addToBookmarksButton: UIBarButtonItem?
    private var goToSourceButton: UIBarButtonItem?
}

// MARK: - Override
extension ArticleViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        load()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if Float(webView.estimatedProgress) == 1.0 {
            progressView.isHidden = true
            
        }
        if keyPath == "estimatedProgress" {
            progressView!.progress = Float(webView.estimatedProgress)
        }
    }
}

// MARK: - Private
private extension ArticleViewController {
    
    func setupView() {
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.setProgress(0.0, animated: true)
        tabBarController?.tabBar.isHidden = true
        
        guard let url = URL(string: (article?.articleUrl)!) else { return }
        webView.load(URLRequest(url: url))
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.allowsBackForwardNavigationGestures = true
        webView.configuration.allowsInlineMediaPlayback = false
        
        addToBookmarksButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.bookmarks, target: self, action: #selector(ArticleViewController.clickAddToBookmarksButton))
        
        goToSourceButton = UIBarButtonItem(title: "Source", style: .plain, target: self, action:
            #selector(ArticleViewController.showAlertMessageGoToTheSource))
        
        navigationItem.rightBarButtonItems = [addToBookmarksButton, goToSourceButton] as? [UIBarButtonItem]
        checkArticleInBookmarks(article: article)
    }
    
    @objc func clickAddToBookmarksButton(_ sender: UIBarButtonItem) {
        do {
            try realm.write {
                realm.add(article!)
                addToBookmarksButton?.isEnabled = false
            }
        } catch {
            print("Error saving article \(error)")
        }
    }
    
    func goToSource() {
        guard let url = URL(string: article!.articleUrl) else { return }
        UIApplication.shared.open(url, options: [:])
    }
    
    @objc func showAlertMessageGoToTheSource(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Open in source?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.goToSource()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func checkArticleInBookmarks(article: Article?) {
        let bookmarksArray : Results<Article> = realm.objects(Article.self)
        for bookmark in bookmarksArray {
            if bookmark.articleUrl == article?.articleUrl {
                addToBookmarksButton?.isEnabled = false
                break
            }
        }
    }
    
    func load() {
        bookmarksArray = realm.objects(Article.self)
    }
}

extension ArticleViewController: WKNavigationDelegate { }

extension ArticleViewController: StoryboardInstantinable { }
