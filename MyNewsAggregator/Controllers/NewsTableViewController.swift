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


class NewsTableViewController: UITableViewController, NetworkProtocol {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var newsTableView: UITableView!
    
    private let connection = ConnectionManager.sharedInstance
    private var emptyLabel: UILabel!
    
    private var gearRefreshControl: GearRefreshControl!
    
    private var newsArray = [Article]()
    let spiner = UIActivityIndicatorView(style: .gray)
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gearRefreshControl = GearRefreshControl(frame: self.view.bounds)
        gearRefreshControl.addTarget(self, action: #selector(NewsTableViewController.refresh), for: UIControl.Event.valueChanged)
        self.refreshControl = gearRefreshControl
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gearRefreshControl.scrollViewDidScroll(scrollView)
    }
    
    @objc func refresh() {
        newsArray.removeAll()
        newsTableView.reloadData()
        spiner.startAnimating()
        NetworkManager.instace.getTopHeadLinesNews(listener: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkCurrentConnection()
    }
    
    // MARK: - Table view data source
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToArticleViewFromNews", sender: self)
        newsTableView.deselectRow(at: indexPath, animated: true)
        self.newsTableView.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destintionVC = segue.destination as! ArticleViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destintionVC.article = newsArray[indexPath.row].copy() as? Article
        }
    }
    
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
    
    private func stopGearRefreshAnimation() {
        let popTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
        DispatchQueue.main.asyncAfter(deadline: popTime) { () -> Void in
            self.gearRefreshControl.endRefreshing()
        }
    }
    
    private func prepareEmptyLabel() {
        emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        emptyLabel.center = CGPoint(x: 160, y: 285)
        emptyLabel.textAlignment = .center
        emptyLabel.text = "No news found"
        emptyLabel.isHidden = true
        self.view.addSubview(emptyLabel)
    }
    
    private func prepareChangeConnectionListener() {
        ConnectionManager.isReachable { _ in
            NetworkManager.instace.getTopHeadLinesNews(listener: self)
            self.gearRefreshControl.gearTintColor = .white
        }
        
        connection.reachability.whenReachable = {
            _ in
            NetworkManager.instace.getTopHeadLinesNews(listener: self)
            self.gearRefreshControl.gearTintColor = .white
        }
        
        connection.reachability.whenUnreachable = {
            _ in
            self.showLostConnectionMessage()
            self.gearRefreshControl.gearTintColor = .red
        }
    }
    
    private func checkCurrentConnection() {
        ConnectionManager.isUnreachable { _ in
            self.showLostConnectionMessage()
            self.gearRefreshControl.gearTintColor = .red
        }
    }
    
    private func showLostConnectionMessage() {
        let dialogMessage = UIAlertController(title: "Lost internet connection", message: "Check connection settings", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { action in
            if self.spiner.isAnimating {
                self.checkCurrentConnection()
            }
        }
        dialogMessage.addAction(okButton)
        self.present(dialogMessage, animated: true, completion: nil)
    }
}

extension NewsTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let inputText = searchBar.text {
            emptyLabel.isHidden = true
            newsArray.removeAll()
            newsTableView.reloadData()
            spiner.startAnimating()
            NetworkManager.instace.getRequestDataNews(request: inputText, listener: self)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            newsArray.removeAll()
            newsTableView.reloadData()
            spiner.startAnimating()
            NetworkManager.instace.getTopHeadLinesNews(listener: self)
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
