//
//  SplashViewController.swift
//  i2tocr-iOS
//
//  Created by bardouei on 8/7/24.
//

import UIKit
import Lottie
import RxSwift
import SwiftyUserDefaults

class SplashViewController: BaseViewController {
    
    @IBOutlet weak var lottieView: LottieAnimationView!
    
    private var disposeBag = DisposeBag()
    private let router = SplashNavigator.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfig()
    }
    
    private func viewConfig() {
        lottiLoad()
    }
    
    private func lottiLoad() {
        lottieView.animation = LottieAnimation.named("OCRScan")
        
        lottieView.play { [weak self] (finished) in
            if finished {
                self?.animationDidFinish()
            }
        }
    }
    
    private func animationDidFinish() {
        let hasSeenIntro = Defaults[\.hasSeenIntro]
        
        if hasSeenIntro {
            router.openBiometricAuthPage(viewController: self)
        } else {
            router.openIntroPage(viewController: self)
        }
    }
}
