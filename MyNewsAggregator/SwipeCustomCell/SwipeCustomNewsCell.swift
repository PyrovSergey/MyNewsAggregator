//
//  SwipeCustomNewsCell.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import Foundation
import SwipeCellKit

class SwipeCustomNewsCell: SwipeTableViewCell  {
    
    @IBOutlet weak var sourceImage: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articlePublicationTimeLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
}
