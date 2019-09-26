//
//  AppCoordinator.swift
//  MyNewsAggregator
//
//  Created by Sergey on 26/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import UIKit

class AppCoordinator {
    
    let window: UIWindow
    let rootViewController: UITabBarController
    
    let newsCoordinator: Coordinator
    let categoriesCoordinator: Coordinator
    let bookmarksCoordinator: Coordinator
    
    init(window: UIWindow) {
        self.window = window
        
        rootViewController = UITabBarController()
        
        let newsRootViewController = UINavigationController()
        newsRootViewController.tabBarItem = UITabBarItem(title: "News",
                                                         image: UIImage(named: "news"),
                                                         selectedImage: nil)
        
        let categoriesRootViewController = UINavigationController()
        categoriesRootViewController.tabBarItem = UITabBarItem(title: "Categories",
                                                               image: UIImage(named: "categories"),
                                                               selectedImage: nil)
        
        let bookmarksRootViewController = UINavigationController()
        bookmarksRootViewController.tabBarItem = UITabBarItem(title: "Bookmarks",
                                                              image: UIImage(named: "bookmarks"),
                                                              selectedImage: nil)
        
        rootViewController.viewControllers = [newsRootViewController, categoriesRootViewController, bookmarksRootViewController]
        
        newsCoordinator = NewsCoordinator(navigationController: newsRootViewController)
        categoriesCoordinator = CategoriesCoordinator(navigationController: categoriesRootViewController)
        bookmarksCoordinator = BookmarksCoordinator(navigationController: bookmarksRootViewController)
    }
}

// MARK: - Coordinator
extension AppCoordinator: Coordinator {
    func start() {
        window.rootViewController = rootViewController
        newsCoordinator.start()
        categoriesCoordinator.start()
        bookmarksCoordinator.start()
        window.makeKeyAndVisible()
    }
}
