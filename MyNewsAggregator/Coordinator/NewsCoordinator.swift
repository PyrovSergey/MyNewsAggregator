//
//  NewsCoordinator.swift
//  MyNewsAggregator
//
//  Created by Sergey on 26/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import UIKit

class NewsCoordinator {
    
    private let navigationController: UINavigationController
    private var newsTableViewController: NewsTableViewController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

// MARK: - Coordinator
extension NewsCoordinator: Coordinator {
    func start() {
        let viewController = NewsTableViewController.instantinateFromStoryboard()
        newsTableViewController = viewController
        navigationController.pushViewController(viewController, animated: true)
    }
}
