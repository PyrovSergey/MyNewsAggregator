//
//  ArticleViewController.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import RxSwift
import WebKit

class ArticleViewController: UIViewController {
    
    var article: Article?

    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!

    private lazy var bookmarksManager = BookmarksManager()
    private var addToBookmarksButton: UIBarButtonItem?
    private var goToSourceButton: UIBarButtonItem?
    private let bag = DisposeBag()
}

// MARK: - Override
extension ArticleViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
        guard let article = article else { return }
        bookmarksManager.add(article: article).subscribe(onCompleted: {
            AlertController.shared.showToast(message: "Bookmark added")
            self.checkArticleInBookmarks(article: article)
        }, onError: { error in
            AlertController.shared.showErrorToast(error: "Error added bookmarks", autoHide: true)
        }).disposed(by: bag)
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
        guard let article = article else { return }
        bookmarksManager.checkArticleInBookmarks(article: article).subscribe(onSuccess: { result in
            self.addToBookmarksButton?.isEnabled = !result
        }).disposed(by: bag)
    }
}

extension ArticleViewController: WKNavigationDelegate { }

extension ArticleViewController: StoryboardInstantinable { }
