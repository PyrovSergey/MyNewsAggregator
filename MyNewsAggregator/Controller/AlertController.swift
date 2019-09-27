//
//  AlertController.swift
//  MyNewsAggregator
//
//  Created by Sergey on 27/09/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import SwiftMessages
import JDStatusBarNotification


public class AlertController {
    public static let shared = AlertController()
}

// MARK: - Public Interface
extension AlertController {
    
    func showErrorToast(error: String, autoHide: Bool = true) {
        
        setErrorToastStyle()
        
        if autoHide {
            JDStatusBarNotification.show(withStatus: error,
                                         dismissAfter: Constants.toastShowDuration,
                                         styleName: Constants.toastErrorStyle)
        } else {
            JDStatusBarNotification.show(withStatus: error,
                                         styleName: Constants.toastErrorStyle)
        }
    }
    
    func showToast(message: String) {
        JDStatusBarNotification.show(withStatus: message,
                                     dismissAfter: Constants.toastShowDuration,
                                     styleName: JDStatusBarStyleSuccess)
    }
    
    func hideToast() {
        JDStatusBarNotification.dismiss(animated: true)
    }
    
    func showProgress() {
        JDStatusBarNotification.show(withStatus: "Loading", styleName: JDStatusBarStyleDefault)
        JDStatusBarNotification.showActivityIndicator(true, indicatorStyle: .gray)
    }
    
    
    func hideProgress() {
        JDStatusBarNotification.dismiss(animated: true)
    }
}

// MARK: - Private
private extension AlertController {
    
    func setErrorToastStyle() {
        JDStatusBarNotification.addStyleNamed(Constants.toastErrorStyle) { (style) -> JDStatusBarStyle? in
            
            style.barColor = UIColor(red: 240.0 / 255.0,
                                     green: 90.0 / 255.0,
                                     blue: 103.0 / 255.0,
                                     alpha: 1.0)
            style.textColor = .white
            return style
        }
    }
}

// MARK: - Constants
private extension AlertController {
    enum Constants {
        static let toastShowDuration: TimeInterval = 1
        static let toastErrorStyle = "ToastErrorStyle"
    }
}
