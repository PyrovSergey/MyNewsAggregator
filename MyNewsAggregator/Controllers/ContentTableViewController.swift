//
//  ContentTableViewController.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import UIKit
import SDWebImage
import GearRefreshControl


class ContentTableViewController: UITableViewController {
    
    private var newsArray = [Article]()
    private let spiner = UIActivityIndicatorView(style: .gray)
    private var emptyLabel: UILabel!
    private var gearRefreshControl: GearRefreshControl!
    
    var parentController: CategoriesUIViewController?
}

// MARK: - Override
extension ContentTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

// MARK: - Public Interface
extension ContentTableViewController {
    
    func setNewListCategoryAndUpdateUI(articleArray: [Article]) {
        print("setNewListCategoryAndUpdateUI --> \(articleArray.count)")
        newsArray = articleArray
        tableView.reloadData()
        spiner.stopAnimating()
        gearRefreshControl.endRefreshing()
        emptyLabel.isHidden = articleArray.count != 0
    }
}

// MARK: - UITableViewDataSource
extension ContentTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! CustomNewsCell
        let currentArticle = newsArray[indexPath.row]
        cell.sourceLabel.text = currentArticle.sourceTitle
        cell.sourceImage.sd_setImage(with: URL(string: currentArticle.sourceImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
        cell.articleTitleLabel.text = currentArticle.articleTitle
        cell.articleImage.sd_setImage(with: URL(string: currentArticle.articleImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
        cell.articlePublicationTimeLabel.text = currentArticle.articlePublicationTime
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ContentTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let storyboard = self.parent?.storyboard {
            let articleViewController = storyboard.instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
            articleViewController.article = newsArray[indexPath.row].copy() as? Article
            navigationController!.pushViewController(articleViewController, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension ContentTableViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gearRefreshControl.scrollViewDidScroll(scrollView)
    }
}

// MARK: - Private
private extension ContentTableViewController {
    
    func setupView() {
        prepareEmptyLabel()
        
        gearRefreshControl = GearRefreshControl(frame: self.view.bounds)
        gearRefreshControl.addTarget(self, action: #selector(ContentTableViewController.refresh), for: UIControl.Event.valueChanged)
        self.refreshControl = gearRefreshControl
        gearRefreshControl.gearTintColor = .white
        
        tableView.backgroundView = spiner
        spiner.startAnimating()
        tableView.register(UINib(nibName: "NewsCell", bundle: nil), forCellReuseIdentifier: "newsCell")
        tableView.separatorStyle = .none
    }
    
    func prepareEmptyLabel() {
        emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        emptyLabel.center = CGPoint(x: 160, y: 285)
        emptyLabel.textAlignment = .center
        emptyLabel.text = "No news found"
        emptyLabel.isHidden = true
        self.view.addSubview(emptyLabel)
    }
    
    @objc func refresh() {
        if let parent = parentController {
            NetworkManager.shared.getUpdateCategoryLists(listener: parent)
        }
    }
    
}
