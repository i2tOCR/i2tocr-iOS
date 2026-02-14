//
//  BaseViewController.swift
//  i2tocr-iOS
//
//  Created by bardouei on 7/12/24.
//


import UIKit
import Lottie
import SwiftyUserDefaults
import AuthenticationServices

protocol RelodableData: AnyObject {
    func retry()
}

class BaseViewController: UIViewController {
    
    var viewcommen: LottieAnimationView!
    var baseActivityIndicator: UIActivityIndicatorView?
    let appearance = UINavigationBarAppearance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.Violet
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        baseActivityIndicator?.stopAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navigationController?.navigationBar.layoutMargins = .zero
        navigationController?.additionalSafeAreaInsets = .zero
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showTabBarWithAnimation() {
        guard let tabBar = tabBarController?.tabBar else { return }
        
        if tabBar.frame.origin.y == UIScreen.main.bounds.height - tabBar.frame.height && !tabBar.isHidden {
            return
        }
        tabBar.isHidden = false
        let initialY = UIScreen.main.bounds.height
        tabBar.frame.origin.y = initialY
        UIView.animate(withDuration: 0.3, animations: {
            tabBar.frame.origin.y = UIScreen.main.bounds.height - tabBar.frame.height
        })
    }
    
    func hideTabBarWithAnimation() {
        guard let tabBar = tabBarController?.tabBar else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            tabBar.frame.origin.y = UIScreen.main.bounds.height
        }) { _ in
            tabBar.isHidden = true
        }
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(title: "Exit", message: "Do You Wanna Exit", preferredStyle: .alert)
        
        // Add a "Cancel" action
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        // Add a "Logout" action
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { _ in
            // Perform logout action here
            Defaults[keyPath: \.isAuthenticated] = false
            let tab = SplashViewController()
            let splashViewController = UINavigationController(rootViewController: tab)
            UIApplication.keyWindow?.rootViewController = splashViewController
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func titleConfig(title: String, backButton: String = "") {
        self.title = title
        self.navigationController?.navigationBar.topItem?.backButtonTitle = backButton
        
        let appearance = UINavigationBarAppearance()
        
        appearance.titleTextAttributes = [
            .foregroundColor: Colors.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = Colors.white
    }
    
    func swipedRightAndUserWantsToDismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addActivityIndicator(viewController: UIViewController, color: UIColor = .gray) {
        if let existingIndicator = self.baseActivityIndicator {
            existingIndicator.removeFromSuperview()
            self.baseActivityIndicator = nil
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = color
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.stopAnimating()
        
        viewController.view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        
        self.baseActivityIndicator = activityIndicator
    }
}
