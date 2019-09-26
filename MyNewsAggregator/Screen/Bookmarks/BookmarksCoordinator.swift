//
//  BookmarksCoordinator.swift
//  MyNewsAggregator
//
//  Created by Sergey on 26/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import UIKit

class BookmarksCoordinator {
    
    private let navigationController: UINavigationController
    private var bookmarksViewController: BookmarksViewController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

// MARK: - Coordinator
extension BookmarksCoordinator: Coordinator {
    func start() {
        let viewController = BookmarksViewController.instantinateFromStoryboard()
        bookmarksViewController = viewController
        navigationController.pushViewController(viewController, animated: true)
    }
}
