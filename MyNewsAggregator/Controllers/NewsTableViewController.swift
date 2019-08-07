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

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var newsTableView: UITableView!
    
    private let connection = ConnectionManager.sharedInstance
    private var emptyLabel: UILabel!
    
    private var gearRefreshControl: GearRefreshControl!
    
    private var newsArray = [Article]()
    private let spiner = UIActivityIndicatorView(style: .gray)
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
        checkCurrentConnection()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destintionVC = segue.destination as! ArticleViewController
        
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        destintionVC.article = newsArray[indexPath.row].copy() as? Article
    }
}

// MARK: - UITableViewDataSource
extension NewsTableViewController {
    
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
        performSegue(withIdentifier: "goToArticleViewFromNews", sender: self)
        newsTableView.deselectRow(at: indexPath, animated: true)
        newsTableView.endEditing(true)
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
        
        gearRefreshControl = GearRefreshControl(frame: self.view.bounds)
        gearRefreshControl.addTarget(self, action: #selector(NewsTableViewController.refresh), for: UIControl.Event.valueChanged)
        refreshControl = gearRefreshControl
        gearRefreshControl.gearTintColor = .white
        
        prepareChangeConnectionListener()
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
    
    func prepareChangeConnectionListener() {
        ConnectionManager.isReachable { _ in
            NetworkManager.shared.getTopHeadLinesNews(listener: self)
            self.gearRefreshControl.gearTintColor = .white
        }
        
        connection.reachability.whenReachable = {
            _ in
            NetworkManager.shared.getTopHeadLinesNews(listener: self)
            self.gearRefreshControl.gearTintColor = .white
        }
        
        connection.reachability.whenUnreachable = {
            _ in
            self.showLostConnectionMessage()
            self.gearRefreshControl.gearTintColor = .red
        }
    }
    
    func checkCurrentConnection() {
        ConnectionManager.isUnreachable { _ in
            self.showLostConnectionMessage()
            self.gearRefreshControl.gearTintColor = .red
        }
    }
    
    func showLostConnectionMessage() {
        let dialogMessage = UIAlertController(title: "Lost internet connection", message: "Check connection settings", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { action in
            if self.spiner.isAnimating {
                self.checkCurrentConnection()
            }
        }
        dialogMessage.addAction(okButton)
        present(dialogMessage, animated: true, completion: nil)
    }
}
