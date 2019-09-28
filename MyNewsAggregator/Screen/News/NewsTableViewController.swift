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
import GearRefreshControl


class NewsTableViewController: UITableViewController {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private var viewModel: NewsViewModel!
    
    private var emptyLabel: UILabel!
    
    private var gearRefreshControl: GearRefreshControl!
    
    private let spiner = UIActivityIndicatorView(style: .gray)
    private let bag = DisposeBag()
}

// MARK: - Override
extension NewsTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.loadNews()
        gearRefreshControl.beginRefreshing()
    }
}

// MARK: - UIScrollViewDelegate
extension NewsTableViewController {
    
    // fix this
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gearRefreshControl.scrollViewDidScroll(scrollView)
    }
}

// MARK: - Private
private extension NewsTableViewController {
    
    func setupView() {
        title = "News"
        
        tableView.delegate = nil
        tableView.dataSource = nil

        gearRefreshControl = GearRefreshControl(frame: self.view.bounds)
        gearRefreshControl.addTarget(self, action: #selector(NewsTableViewController.refresh), for: UIControl.Event.valueChanged)
        refreshControl = gearRefreshControl
        gearRefreshControl.gearTintColor = .white

        prepareEmptyLabel()
        spiner.startAnimating()
        tableView.keyboardDismissMode = .onDrag
        searchBar.placeholder = "Search news"
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "newsCell")
        tableView.separatorStyle = .none
        tableView.backgroundView = spiner
        
        viewModel
            .articles
            .drive(tableView.rx.items(cellIdentifier: "newsCell", cellType: NewsCell.self)) { row, element, cell in
            cell.sourceLabel.text = element.sourceTitle
            cell.sourceImage.sd_setImage(with: URL(string: element.sourceImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
            cell.articleTitleLabel.text = element.articleTitle
            cell.articleImage.sd_setImage(with: URL(string: element.articleImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
            cell.articlePublicationTimeLabel.text = Utils.getDateFromApi(date: element.articlePublicationTime).timeAgoSinceNow
        }.disposed(by: bag)
        
        viewModel.articles
            .map{ !$0.isEmpty }
            .drive(emptyLabel.rx.isHidden)
            .disposed(by: bag)
        
        
        tableView.rx
            .modelSelected(Article.self).subscribe(onNext: { [weak self] article in
            self?.startArticleViewController(article: article)
        }).disposed(by: bag)
        
        tableView.rx.contentOffset.subscribe {
            print("offset now \($0.element)")
        }.disposed(by: bag)
        
    }
    
    @objc func refresh() {
        spiner.startAnimating()
        viewModel.loadNews()
    }
    
    func stopGearRefreshAnimation() {
        let popTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: popTime) { () -> Void in
            self.gearRefreshControl.endRefreshing()
        }
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
        viewController.article = article
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - StoryboardInstantinable
extension NewsTableViewController: StoryboardInstantinable {}
