//
//  ViewController.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import UIKit
import SwipeMenuViewController
import Alamofire
import SwiftyJSON


class CategoriesViewController: SwipeMenuViewController {
    
    private lazy var swipeCategory = Utils.getCategories()
    private var arrayControllers = [String : CategoryTableViewController]()
    
    private var options = SwipeMenuViewOptions()
    private var dataCount: Int = 6
    private var firstOpening: Bool = true
    
    // MARK: - SwipeMenuViewDelegate
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) {
        super.swipeMenuView(swipeMenuView, viewWillSetupAt: currentIndex)
        //print("will setup SwipeMenuView")
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) {
        super.swipeMenuView(swipeMenuView, viewDidSetupAt: currentIndex)
        //print("did setup SwipeMenuView")
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        super.swipeMenuView(swipeMenuView, willChangeIndexFrom: fromIndex, to: toIndex)
        //print("will change from section\(fromIndex + 1)  to section\(toIndex + 1)")
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        super.swipeMenuView(swipeMenuView, didChangeIndexFrom: fromIndex, to: toIndex)
        //print("did change from section\(fromIndex + 1)  to section\(toIndex + 1)")
    }
    
    // MARK: - SwipeMenuViewDelegate
    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return dataCount
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return children[index].title ?? ""
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let viewController = children[index]
        viewController.didMove(toParent: self)
        return viewController
    }
}

// MARK: - Override
extension CategoriesViewController {
    
    override func viewDidLoad() {
        swipeCategory.forEach { categoryName in
            let viewController = CategoryTableViewController()
            arrayControllers[categoryName] = viewController
            viewController.title = categoryName
            viewController.viewModel = CategoryViewModel(categoryName: categoryName)
            self.addChild(viewController)
        }
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstOpening {
            reload()
            firstOpening = false
        }
    }
}

// MARK: - Private
private extension CategoriesViewController {
    
    func setupView() {
        title = "Categories"
    }
    
    func reload() {
        swipeMenuView.reloadData(options: options)
    }
}

// MARK: - StoryboardInstantinable
extension CategoriesViewController: StoryboardInstantinable {}
