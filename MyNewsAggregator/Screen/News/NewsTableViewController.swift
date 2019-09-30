//
//  NewsTableViewController.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import RxCocoa
import RxSwift
import SDWebImage


class NewsTableViewController: UITableViewController {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private var viewModel: NewsViewModel!
    
    private var emptyLabel: UILabel!
    private let customRefreshControl = UIRefreshControl()
    private let spiner = UIActivityIndicatorView(style: .gray)
    private let bag = DisposeBag()
}

// MARK: - Override
extension NewsTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        refresh()
    }
}

// MARK: - Private
private extension NewsTableViewController {
    
    func setupView() {
        title = "News"
        
        prepareEmptyLabel()
        
        tableView.delegate = nil
        tableView.dataSource = nil

        spiner.startAnimating()
        tableView.backgroundView = spiner
        
        tableView.keyboardDismissMode = .onDrag
        searchBar.placeholder = "Search news"
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "newsCell")
        tableView.separatorStyle = .none
        
        
        tableView.refreshControl = customRefreshControl
        customRefreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    func bind() {
        
        tableView.rx
            .modelSelected(Article.self)
            .subscribe(onNext: { [weak self] article in
                self?.startArticleViewController(article: article)
            }).disposed(by: bag)
        
        viewModel
            .articles
            .drive(tableView.rx.items(cellIdentifier: "newsCell", cellType: NewsCell.self)) { row, element, cell in
                cell.sourceLabel.text = element.sourceTitle
                cell.sourceImage.sd_setImage(with: URL(string: element.sourceImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
                cell.articleTitleLabel.text = element.articleTitle
                cell.articleImage.sd_setImage(with: URL(string: element.articleImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
                cell.articlePublicationTimeLabel.text = Utils.getDateFromApi(date: element.articlePublicationTime).timeAgoSinceNow
            }.disposed(by: bag)
        
        viewModel
            .articles
            .map{ !$0.isEmpty }
            .skip(1)
            .drive(emptyLabel.rx.isHidden)
            .disposed(by: bag)
        
        viewModel
            .articles
            .distinctUntilChanged()
            .asObservable()
            .subscribe { _ in
                self.spiner.stopAnimating()
                self.customRefreshControl.endRefreshing()
            }.disposed(by: bag)
        
        searchBar.rx
            .text
            .orEmpty
            .bind(to: viewModel.searchText)
            .disposed(by: bag)
        
        searchBar.rx
            .text
            .distinctUntilChanged()
            .map { $0! }
            .filter { $0.isEmpty }
            .subscribe(onNext: { _ in
            self.refresh()
        }).disposed(by: bag)
        
        searchBar.rx
            .searchButtonClicked
            .asObservable()
            .subscribe(onNext: {
                self.viewModel.searchNews()
            }).disposed(by: bag)
    }
    
    @objc func refresh() {
        
        spiner.startAnimating()
        searchBar.text?.removeAll()
        viewModel.loadNews()
    }
    
    func prepareEmptyLabel() {
        
        emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        emptyLabel.center = CGPoint(x: view.center.x, y: view.center.y)
        emptyLabel.textAlignment = .center
        emptyLabel.text = "No news found"
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
    }
    
    func startArticleViewController(article: Article) {
        
        let viewController = ArticleViewController.instantinateFromStoryboard()
        viewController.article = article.copy() as? Article
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - StoryboardInstantinable
extension NewsTableViewController: StoryboardInstantinable {}
