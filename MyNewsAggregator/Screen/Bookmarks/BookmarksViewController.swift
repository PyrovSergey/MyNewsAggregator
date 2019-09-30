//
//  BookmarksTableViewController.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import RxSwift
import RxCocoa
import SwipeCellKit

class BookmarksViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyLabel: UILabel!
    @IBOutlet private var viewModel: BookmarksViewModel!
    
    private let bag = DisposeBag()
}

// MARK: - Override
extension BookmarksViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }
}

// MARK: - SwipeTableViewCellDelegate
extension BookmarksViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.viewModel.delete(at: indexPath)
        }
        deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .border
        return options
    }
}

// MARK: - Private
private extension BookmarksViewController {
    
    func setupView() {
        
        title = "Bookmarks"
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "BookmarkCell", bundle: nil), forCellReuseIdentifier: "bookmarkCell")
        
    }
    
    func bind() {
        
        tableView.rx
            .modelSelected(Article.self)
            .subscribe(onNext: { [weak self] article in
                self?.startArticleViewController(article: article)
            }).disposed(by: bag)
        
        viewModel
            .bookmarks
            .drive(tableView.rx.items(cellIdentifier: "bookmarkCell", cellType: BookmarkCell.self)) { row, element, cell in
                cell.delegate = self
                cell.viewModel = element
            }.disposed(by: bag)
        
        viewModel
            .bookmarks
            .map{ !$0.isEmpty }
            .skip(1)
            .drive(emptyLabel.rx.isHidden)
            .disposed(by: bag)
    }
    
    func startArticleViewController(article: Article) {
        
        let viewController = ArticleViewController.instantinateFromStoryboard()
        viewController.article = article.copy() as? Article
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - StoryboardInstantinable
extension BookmarksViewController: StoryboardInstantinable {}
