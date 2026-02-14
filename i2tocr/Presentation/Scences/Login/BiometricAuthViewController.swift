//
//  BiometricAuthViewController.swift
//  i2tocr-iOS
//
//  Created by baner on 11/9/25.
//

import UIKit
import LocalAuthentication
import SwiftyUserDefaults

class BiometricAuthViewController: BaseViewController {
    
    private let context = LAContext()
    private var error: NSError?
    let homeRouter = HomeNavigatorRoute.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startBiometricAuth()
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.Violet
        
        let titleLabel = UILabel()
        titleLabel.text = "Login to App"
        titleLabel.textColor = Colors.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Please verify your identity"
        subtitleLabel.textColor = Colors.white
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let biometricImage = UIImageView()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            let biometricType = context.biometryType
            switch biometricType {
            case .faceID:
                biometricImage.image = UIImage(systemName: "faceid")
            case .touchID:
                biometricImage.image = UIImage(systemName: "touchid")
            default:
                biometricImage.image = UIImage(systemName: "lock.shield")
            }
        } else {
            biometricImage.image = UIImage(systemName: "lock.shield")
        }
        biometricImage.tintColor = .white
        biometricImage.contentMode = .scaleAspectFit
        biometricImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(biometricImage)
        
        NSLayoutConstraint.activate([
            biometricImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            biometricImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            biometricImage.widthAnchor.constraint(equalToConstant: 80),
            biometricImage.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.bottomAnchor.constraint(equalTo: biometricImage.topAnchor, constant: -40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: biometricImage.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func startBiometricAuth() {
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            authenticateWithBiometrics()
        } else {
            authenticateWithDevicePasscode()
        }
    }
    
    private func authenticateWithBiometrics() {
        let reason = "To access the app, please verify your identity"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.authenticationSuccess()
                } else {
                    if let error = error as? LAError {
                        self?.handleBiometricError(error)
                    } else {
                        self?.authenticateWithDevicePasscode()
                    }
                }
            }
        }
    }
    
    private func authenticateWithDevicePasscode() {
        let reason = "To access the app, please verify your identity"
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.authenticationSuccess()
                } else {
                    self?.showRetryAlert()
                }
            }
        }
    }
    
    private func handleBiometricError(_ error: LAError) {
        switch error.code {
        case .userCancel, .userFallback, .appCancel, .systemCancel:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.startBiometricAuth()
            }
        case .authenticationFailed:
            showRetryAlert()
            
        case .passcodeNotSet:
            showPasscodeNotSetAlert()
            
        case .biometryNotAvailable:
            authenticateWithDevicePasscode()
            
        case .biometryNotEnrolled:
            showBiometricNotEnrolledAlert()
            
        case .biometryLockout:
            showBiometricLockoutAlert()
            
        default:
            authenticateWithDevicePasscode()
        }
    }
    
    private func authenticationSuccess() {
        Defaults[\.isAuthenticated] = true
        homeRouter.openHomePage(viewController: self)
    }
    
    private func showRetryAlert() {
        let alert = UIAlertController(
            title: "Authentication Failed",
            message: "Please try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.startBiometricAuth()
        })
        present(alert, animated: true)
    }
    
    private func showPasscodeNotSetAlert() {
        let alert = UIAlertController(
            title: "Passcode Not Set",
            message: "Please set up a passcode in your device settings.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showBiometricNotEnrolledAlert() {
        let alert = UIAlertController(
            title: "Biometric Not Enrolled",
            message: "Please set up Face ID or Touch ID in your device settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.authenticateWithDevicePasscode()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showBiometricLockoutAlert() {
        let alert = UIAlertController(
            title: "Biometric Locked",
            message: "Biometric authentication is temporarily locked. Please use your device passcode.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Use Passcode", style: .default) { [weak self] _ in
            self?.authenticateWithDevicePasscode()
        })
        
        present(alert, animated: true)
    }
}
