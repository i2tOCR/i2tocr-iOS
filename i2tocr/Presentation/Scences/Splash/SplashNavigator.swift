//
//  SplashNavigator.swift
//  i2tocr-iOS
//
//  Created by bardouei on 8/17/24.
//

import UIKit

class SplashNavigator {
    
    static let shared = SplashNavigator()
    
    private init() {}
    
    func openIntroPage(viewController: UIViewController) {
        let vc = IntroPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        let navigationController = UINavigationController(rootViewController: vc)
        UIApplication.keyWindow?.rootViewController = navigationController
    }
    
    func openBiometricAuthPage(viewController: UIViewController) {
        let vc = BiometricAuthViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        UIApplication.keyWindow?.rootViewController = navigationController
    }
    
    func openHomePage(viewController: UIViewController) {
        let vc = HomeViewController()
//        let vc = HomeViewController(nibName: "HomeViewController", bundle: nil)
        let navigationController = UINavigationController(rootViewController: vc)
        UIApplication.keyWindow?.rootViewController = navigationController
    }
}
