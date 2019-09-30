//
//  TableViewCellViewModelType.swift
//  MyNewsAggregator
//
//  Created by Sergey on 30/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import Foundation

protocol TableViewCellViewModelType: class {
    
    var sourceTitle: String { get set }
    var sourceImageUrl: String { get set }
    var articleTitle: String { get set }
    var articleImageUrl: String { get set }
    var articleUrl: String { get set }
    var articlePublicationTime: String { get set }
}
