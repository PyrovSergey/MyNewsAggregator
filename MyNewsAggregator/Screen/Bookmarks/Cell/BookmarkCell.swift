//
//  SwipeCustomNewsCell.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import SwipeCellKit
import SDWebImage

class BookmarkCell: SwipeTableViewCell  {
    
    @IBOutlet private weak var sourceImage: UIImageView!
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var articleTitleLabel: UILabel!
    @IBOutlet private weak var articlePublicationTimeLabel: UILabel!
    @IBOutlet private weak var articleImage: UIImageView!
    
    weak var viewModel: TableViewCellViewModelType? {
        willSet(viewModel) {
            guard let viewModel = viewModel else { return }
            sourceLabel.text = viewModel.sourceTitle
            sourceImage.sd_setImage(with: URL(string: viewModel.sourceImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
            articleTitleLabel.text = viewModel.articleTitle
            articleImage.sd_setImage(with: URL(string: viewModel.articleImageUrl), placeholderImage: UIImage(named: "news-placeholder.jpg"))
            articlePublicationTimeLabel.text = Utils.getDateFromApi(date: viewModel.articlePublicationTime).timeAgoSinceNow
        }
    }
}
