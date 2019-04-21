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

class BookmarksViewController: UIViewController, SwipeTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private let realm = try! Realm()
    private var bookmarksArray : Results<Article>?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelBookmarksIsEmpty: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SwipeCustomNewsCell", bundle: nil), forCellReuseIdentifier: "swipeCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        load()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        labelBookmarksIsEmpty.isHidden = (bookmarksArray?.count)! != 0
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt --> \(indexPath.row)")
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
}
