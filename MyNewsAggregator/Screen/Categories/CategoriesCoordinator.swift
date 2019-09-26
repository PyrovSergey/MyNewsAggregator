//
//  CategoriesCoordinator.swift
//  MyNewsAggregator
//
//  Created by Sergey on 26/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import UIKit

class CategoriesCoordinator {
    
    private let navigationController: UINavigationController
    private var categoriesViewController: CategoriesViewController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

// MARK: - Coordinator
extension CategoriesCoordinator: Coordinator {
    func start() {
        let viewController = CategoriesViewController.instantinateFromStoryboard()
        categoriesViewController = viewController
        navigationController.pushViewController(viewController, animated: true)
    }
}
