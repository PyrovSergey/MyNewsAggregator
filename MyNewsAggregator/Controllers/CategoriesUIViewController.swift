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

class CategoriesUIViewController: SwipeMenuViewController, NetworkProtocol {
    
    private let arraySwipe = ["General", "Entertainment", "Sport", "Technology", "Health", "Business"]
    private var arrayControllers = [String : ContentTableViewController]()
    
    private var options = SwipeMenuViewOptions()
    private var dataCount: Int = 6
    private var firstOpening: Bool = true
    
    override func viewDidLoad() {
        arraySwipe.forEach { data in
            let vc = ContentTableViewController()
            arrayControllers[data] = vc
            vc.title = data
            vc.parentController = self
            self.addChild(vc)
        }
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NetworkManager.instace.getUpdateCategoryLists(listener: self)
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if firstOpening {
            reload()
            firstOpening = false
        }
    }
    
    func successRequest(result: [Article], category: String) {
        let vc = arrayControllers[category]
        vc?.setNewListCategoryAndUpdateUI(articleArray: result)
    }
    
    func errorRequest(errorMessage: String) {
        
    }
    
    private func reload() {
        swipeMenuView.reloadData(options: options)
    }
    
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
    
    
    // MARK - SwipeMenuViewDataSource
    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return dataCount
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return children[index].title ?? ""
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let vc = children[index]
        vc.didMove(toParent: self)
        return vc
    }
}

