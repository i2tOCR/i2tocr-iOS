//
//  HomeNavigator.swift
//  i2tocr-iOS
//
//  Created by bardouei on 8/18/24.
//

import UIKit

protocol HomeNavigator {
    func openScanPage(viewController: UIViewController, document: DocumentObject)
    func openHomePage(viewController: UIViewController)
}

struct HomeNavigatorRoute: HomeNavigator {
    
    static let sharedInstance = HomeNavigatorRoute()
    
    private init() {}
    
    func openScanPage(viewController: UIViewController, document: DocumentObject) {
        let detailVC = MyScanDetailViewController()
        detailVC.document = document
        viewController.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func openHomePage(viewController: UIViewController) {
        let vc = HomeViewController()
        viewController.navigationController?.pushViewController(vc, animated: true)
    }
}
