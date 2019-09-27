//
//  NewsTableViewController.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import UIKit
import SDWebImage
import GearRefreshControl


class NewsTableViewController: UITableViewController {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var newsTableView: UITableView!
    @IBOutlet private var viewModel: NewsViewModel!
    
    private var emptyLabel: UILabel!
    
    private var gearRefreshControl: GearRefreshControl!
    
    private var newsArray = [Article]()
    private let spiner = UIActivityIndicatorView(style: .gray)
}

// MARK: - Override
extension NewsTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        NetworkManager.shared.getTopHeadLinesNews(listener: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - UISearchBarDelegate
extension NewsTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let inputText = searchBar.text {
            emptyLabel.isHidden = true
            newsArray.removeAll()
            newsTableView.reloadData()
            spiner.startAnimating()
            NetworkManager.shared.getRequestDataNews(request: inputText, listener: self)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            newsArray.removeAll()
            newsTableView.reloadData()
            spiner.startAnimating()
            NetworkManager.shared.getTopHeadLinesNews(listener: self)
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension NewsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsCell
        let currentArticle = newsArray[indexPath.row]
        cell.sourceLabel.text = currentArticle.sourceTitle
        cell.sourceImage.sd_setImage(with: URL(string: currentArticle.sourceImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
        cell.articleTitleLabel.text = currentArticle.articleTitle
        cell.articleImage.sd_setImage(with: URL(string: currentArticle.articleImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
        cell.articlePublicationTimeLabel.text = currentArticle.articlePublicationTime
        return cell
    }
}

// MARK: - NetworkProtocol
extension NewsTableViewController: NetworkProtocol {
    
    func successRequest(result: [Article], category: String) {
        emptyLabel.isHidden = result.count != 0
        newsArray = result
        spiner.stopAnimating()
        stopGearRefreshAnimation()
        newsTableView.reloadData()
    }
    
    func errorRequest(errorMessage: String) {
        print(errorMessage)
        gearRefreshControl.gearTintColor = .red
    }
}

// MARK: - UITableViewDelegate
extension NewsTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = ArticleViewController.instantinateFromStoryboard()
        viewController.article = newsArray[indexPath.row].copy() as? Article
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension NewsTableViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gearRefreshControl.scrollViewDidScroll(scrollView)
    }
}

// MARK: - Private
private extension NewsTableViewController {
    
    func setupView() {
        title = "News"

        gearRefreshControl = GearRefreshControl(frame: self.view.bounds)
        gearRefreshControl.addTarget(self, action: #selector(NewsTableViewController.refresh), for: UIControl.Event.valueChanged)
        refreshControl = gearRefreshControl
        gearRefreshControl.gearTintColor = .white

        prepareEmptyLabel()
        spiner.startAnimating()
        newsTableView.keyboardDismissMode = .onDrag
        searchBar.delegate = self
        searchBar.placeholder = "Search news"
        newsTableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "newsCell")
        newsTableView.separatorStyle = .none
        newsTableView.backgroundView = spiner
    }
    
    @objc func refresh() {
        newsArray.removeAll()
        newsTableView.reloadData()
        spiner.startAnimating()
        NetworkManager.shared.getTopHeadLinesNews(listener: self)
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
}

// MARK: - StoryboardInstantinable
extension NewsTableViewController: StoryboardInstantinable {}
