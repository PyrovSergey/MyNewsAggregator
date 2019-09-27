//
//  ConnectionManager.swift
//  MyNewsAggregator
//
//  Created by Sergey on 11/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import Reachability


class ConnectionManager: NSObject {
    
    static let shared = ConnectionManager()
    
    private(set) var isConnected: Bool = true {
        didSet {
            updateViewState()
        }
    }
    
    private override init() {
        super.init()
        
        reachability = Reachability()
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    private var reachability: Reachability?
}

// MARK: - Public Interface
extension ConnectionManager {
    
    func beginObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkStatusChanged),
                                               name: .reachabilityChanged,
                                               object: reachability)
    }
    
    func endObserver() {
        reachability?.stopNotifier()
    }
}

// MARK: - Private
private extension ConnectionManager {
    
    func updateViewState() {
        
        if isConnected {
            AlertController.shared.hideToast()
        } else {
            AlertController.shared.showErrorToast(error: "No connection",
                                                  autoHide: false)
        }
    }
    
    @objc func networkStatusChanged() {
        
        guard let connection = reachability?.connection else {
            isConnected = false
            return
        }
        isConnected = connection != .none
    }
}
