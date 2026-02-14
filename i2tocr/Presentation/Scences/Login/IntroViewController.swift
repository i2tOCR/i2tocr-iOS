//
//  IntroViewController.swift
//  i2tocr-iOS
//
//  Created by bardouei on 8/17/24.
//
//

import UIKit
import RxSwift
import SwiftyUserDefaults

class IntroViewController: BaseViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bioButton: CButton!
    
    private let router = SplashNavigator.shared
    var imageName: String?
    var descriptionText: String?
    var currentPage: Int = 0
    var totalPages: Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfig()
    }
    
    @IBAction func bioButtonTapped(_ sender: Any) {
        self.goToBiometricAuth()
    }
    
    private func viewConfig() {
        imageView.image = UIImage(named: imageName ?? "")
        imageView.layer.cornerRadius = 32
        descriptionLabel.text = descriptionText
        descriptionLabel.textColor = Colors.white
        descriptionLabel.font = UIFont(name: Fonts.cruiser, size: 12)
        
        if currentPage == 2 {
            bioButton.isHidden = false
            bioButton.setTitle("Start", for: .normal)
            bioButton.backgroundColor = Colors.blue
            bioButton.setTitleColor(Colors.Violet, for: .normal)
        } else {
            bioButton.isHidden = true
        }
    }
    
    private func goToBiometricAuth() {
        Defaults[\.hasSeenIntro] = true
        router.openBiometricAuthPage(viewController: self)
    }
}
