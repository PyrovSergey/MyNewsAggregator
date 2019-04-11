//
//  BookmarksTableViewController.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class BookmarksTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    private let realm = try! Realm()
    private var emptyLabel: UILabel!
    private var bookmarksArray : Results<Article>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareEmptyLabel()
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SwipeCustomNewsCell", bundle: nil), forCellReuseIdentifier: "swipeCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        load()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "swipeCell", for: indexPath) as! SwipeCustomNewsCell
        if (bookmarksArray?.count)! > 0 {
            cell.delegate = self
            let currentArticle: Article = bookmarksArray![indexPath.row]
            cell.sourceLabel.text = currentArticle.sourceTitle
            cell.sourceImage.sd_setImage(with: URL(string: currentArticle.sourceImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
            cell.articleTitleLabel.text = currentArticle.articleTitle
            cell.articleImage.sd_setImage(with: URL(string: currentArticle.articleImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
            cell.articlePublicationTimeLabel.text = currentArticle.articlePublicationTime
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyLabel.isHidden = (bookmarksArray?.count)! != 0
        return (bookmarksArray?.count)!
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.updateModel(at: indexPath)
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToArticleViewFromBookmarks", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destintionVC = segue.destination as! ArticleViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destintionVC.article = bookmarksArray![indexPath.row]
        }
    }
    
    private func load() {
        bookmarksArray = realm.objects(Article.self)
        tableView.reloadData()
    }
    
    private func updateModel(at indexPath: IndexPath) {
        if let bookmark = self.bookmarksArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(bookmark)
                }
            } catch {
                print("Error deleting bookmark \(error)")
            }
        }
    }
    
    func showEmptyLabel() {
        emptyLabel.isHidden = false
    }
    
    private func prepareEmptyLabel() {
        emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        emptyLabel.center = CGPoint(x: 160, y: 285)
        emptyLabel.textAlignment = .center
        emptyLabel.text = "Bookmark list is empty"
        emptyLabel.isHidden = true
        self.view.addSubview(emptyLabel)
    }
}
