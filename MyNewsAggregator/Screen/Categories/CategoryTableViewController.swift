//
//  CategoryTableViewController.swift
//  MyNewsAggregator
//
//  Created by Sergey on 30/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import RxCocoa
import RxSwift
import SDWebImage

class CategoryTableViewController: UITableViewController {
    
    var viewModel: CategoryViewModel?
    
    private let customRefreshControl = UIRefreshControl()
    private let spiner = UIActivityIndicatorView(style: .gray)
    private let bag = DisposeBag()
}

// MARK: - Override
extension CategoryTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        refresh()
    }
}

// MARK: - Private
private extension CategoryTableViewController {
    
    func setupView() {

        tableView.delegate = nil
        tableView.dataSource = nil
        
        spiner.startAnimating()
        tableView.backgroundView = spiner
        
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
        
        viewModel?
            .articles
            .drive(tableView.rx.items(cellIdentifier: "newsCell", cellType: NewsCell.self)) { row, element, cell in
                cell.sourceLabel.text = element.sourceTitle
                cell.sourceImage.sd_setImage(with: URL(string: element.sourceImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
                cell.articleTitleLabel.text = element.articleTitle
                cell.articleImage.sd_setImage(with: URL(string: element.articleImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
                cell.articlePublicationTimeLabel.text = Utils.getDateFromApi(date: element.articlePublicationTime).timeAgoSinceNow
            }.disposed(by: bag)
        
        viewModel?
            .articles
            .distinctUntilChanged()
            .asObservable()
            .subscribe { _ in
                self.spiner.stopAnimating()
                self.customRefreshControl.endRefreshing()
            }.disposed(by: bag)
    }
    
    func startArticleViewController(article: Article) {
        
        let viewController = ArticleViewController.instantinateFromStoryboard()
        viewController.article = article.copy() as? Article
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func refresh() {
        self.spiner.startAnimating()
        viewModel?.updateCategoryNews()
    }
}
