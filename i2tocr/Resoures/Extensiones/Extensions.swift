//
//  Extensions.swift
//  i2tocr-iOS
//
//  Created by bardouei on 7/12/24.
//

import UIKit
import SwiftyUserDefaults


protocol Reusable: AnyObject {}

extension UITableViewCell: Reusable {}
extension UICollectionViewCell: Reusable{}
extension UIViewController: Reusable {}

// MARK: extension UITableView
extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) {
        let Nib = UINib.init(nibName: T.reusedId, bundle: nil)
        register(Nib, forCellReuseIdentifier: T.reusedId)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reusedId, for: indexPath as IndexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reusedId)")
        }
        return cell
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type){
        let nib = UINib.init(nibName: T.reusedId, bundle: nil)
        register(nib, forCellWithReuseIdentifier: T.reusedId)
    }
}

extension Reusable {
    static var reusedId: String {
        return String(describing: self)
    }
}

extension UIStoryboard {
    func instantiateViewController<T>(ofType type: T.Type = T.self) -> T where T: UIViewController {
        guard let viewController = instantiateViewController(withIdentifier: type.reusedId) as? T else {
            fatalError()
        }
        return viewController
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: Bundle.main, value: "", comment: "")
    }
}

//// MARK: extension UIViewController
extension UIViewController {
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let CencleAction = UIAlertAction(title: "Cencle", style: .cancel, handler: nil)
        let OKAction = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
            let vc = SplashViewController()
            UIApplication.keyWindow?.rootViewController = vc
        }
        alertController.addAction(CencleAction)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

//// MARK: extension UIApplication
extension UIApplication {
    class var topViewController: UIViewController? { return getTopViewController() }
    private class func getTopViewController(
        base: UIViewController? = UIApplication.keyWindow?.rootViewController) -> UIViewController? {
            if let nav = base as? UINavigationController { return getTopViewController(base: nav.visibleViewController) }
            if let tab = base as? UITabBarController {
                if let selected = tab.selectedViewController { return getTopViewController(base: selected) }
            }
            if let presented = base?.presentedViewController { return getTopViewController(base: presented) }
            return base
        }
    
    static var keyWindow: UIWindow? {
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first
        return windowScene?.windows.first(where: { $0.isKeyWindow })
    }
}
