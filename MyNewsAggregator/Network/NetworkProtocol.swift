//
//  NetworkProtocol.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import Foundation

protocol NetworkProtocol {
    func successRequest(result: [Article], category: String)
    
    func errorRequest(errorMessage: String)
}
