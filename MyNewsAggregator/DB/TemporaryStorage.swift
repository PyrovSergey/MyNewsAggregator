//
//  TemporaryStorage.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import Foundation

class TemporaryStorage {
    
    static let shared = TemporaryStorage()
    
    private var generalCategory = [Article]()
    private var entertainmentCategory = [Article]()
    private var sportsCategory = [Article]()
    private var technologyCategory = [Article]()
    private var healthCategory = [Article]()
    private var businessCategory = [Article]()
    private var mainNewsCategory = [Article]()
    
    private init() {}
}

// MARK: - Public Interface
extension TemporaryStorage {
    
    func getCategoryList(categoryName: String) -> [Article] {
        switch categoryName {
        case "General":
            return generalCategory
        case "Entertainment":
            return entertainmentCategory
        case "Sports":
            return sportsCategory
        case "Technology":
            return technologyCategory
        case "Health":
            return healthCategory
        case "Business":
            return businessCategory
        default:
            return mainNewsCategory
        }
    }
    
    func setCategoryList(result: [Article], categoryName: String) {
        switch categoryName {
        case "General":
            generalCategory = result
        case "Entertainment":
            entertainmentCategory = result
        case "Sports":
            sportsCategory = result
        case "Technology":
            technologyCategory = result
        case "Health":
            healthCategory = result
        case "Business":
            businessCategory = result
        default:
            mainNewsCategory = result
        }
    }
}
