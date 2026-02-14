//
//  LoginNavigator.swift
//  i2tocr-iOS
//
//  Created by bardouei on 8/17/24.
//

import UIKit

struct LoginNavigator {
    
    static let shared = LoginNavigator()
    
    private init() {}
    
    func openHomePage(viewController: UIViewController) {
        let vc = HomeViewController()
        viewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openBiometricAuthPage(viewController: UIViewController) {
        let vc = BiometricAuthViewController()
        viewController.navigationController?.pushViewController(vc, animated: true)
    }
}
