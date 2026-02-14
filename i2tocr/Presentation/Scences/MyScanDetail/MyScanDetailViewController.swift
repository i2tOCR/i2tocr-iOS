//
// MyScanDetailViewController.swift
// i2tocr-iOS
//
// Created by bardouei on 12/6/24.
//
//

import UIKit

// Assumes existence of BaseViewController, HomeViewModel, and DocumentObject
class MyScanDetailViewController: BaseViewController {
    
    // MARK: - Dependencies
    @Inject private var viewModel: HomeViewModel
    
    // MARK: - Properties
    var document: DocumentObject?
    private var activityIndicator: UIActivityIndicatorView!
    
    // UI Bar Button Items
    private var saveButton: UIBarButtonItem!
    
    // Stores the original text to compare for changes
    private var originalText: String = ""
    
    // MARK: - IBOutlets
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var documentImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        setupTextView()
        // Combine setup for Copy and Save buttons
        setupSaveAndCopyButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // Show loading indicator
        showLoading()
        
        // Simulate loading/OCR process
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.configureWithDocument()
            self?.hideLoading()
            
            // Configure UI after loading
            self?.backView.backgroundColor = Colors.grey3
            
            self?.documentImageView.layer.cornerRadius = 64
            self?.documentImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            self?.backView.layer.cornerRadius = 64
            self?.backView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .systemGray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTextView() {
        // Enable text selection and editing
        textView.isSelectable = true
        textView.isEditable = true // Enable editing/typing/deleting
        textView.isUserInteractionEnabled = true
        textView.delegate = self // Set the delegate to track changes
        
        // Clear background
        textView.backgroundColor = .clear
        textView.textColor = .label
        
        // Remove padding and make transparent
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.isOpaque = false
    }
    
    private func setupSaveAndCopyButtons() {
        
        // 1. Copy Button
        let copyButton = UIBarButtonItem(
            image: UIImage(systemName: "doc.on.doc"),
            style: .plain,
            target: self,
            action: #selector(copyButtonTapped)
        )
        
        // 2. Save Button (similar style to Copy)
        saveButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.down"), // Icon for Save
            style: .plain,
            target: self,
            action: #selector(saveButtonTapped)
        )
        
        // Initially disable Save button until text changes
        saveButton.isEnabled = false
        
        // Place both buttons on the right side of the navigation bar
        // Order: [Copy, Save]
        navigationItem.rightBarButtonItems = [copyButton, saveButton]
    }
    
    // MARK: - Action Handlers
    
    @objc private func copyButtonTapped() {
        guard let text = textView.text, !text.isEmpty else {
            showBannerAlert(message: "No text to copy")
            return
        }
        
        // Copy the entire text in the TextView to the clipboard
        UIPasteboard.general.string = text
        showBannerAlert(message: "Text copied to clipboard")
    }
    
    @objc private func saveButtonTapped() {
        guard let document = document,
              let newText = textView.text,
              newText != originalText
        else {
            return
        }
        
        // Update the document through the ViewModel (assumed method)
//        viewModel.updateDocumentText(id: document.id, newText: newText)
        
        // Update local state
        originalText = newText
        self.document?.textDic = newText // Update the local document object if needed
        saveButton.isEnabled = false
        
        showBannerAlert(message: "Document saved successfully")
    }
    
    // MARK: - UI Configuration & Helpers
    
    
    private func showLoading() {
        // Hide all content views
        backView.isHidden = true
        documentImageView.isHidden = true
        textView.isHidden = true
        
        // Show activity indicator
        activityIndicator.startAnimating()
        view.bringSubviewToFront(activityIndicator)
    }
    
    private func hideLoading() {
        // Show all content views
        backView.isHidden = false
        documentImageView.isHidden = false
        textView.isHidden = false
        
        // Hide activity indicator
        activityIndicator.stopAnimating()
    }
    
    private func configureWithDocument() {
        guard let document = document else { return }
        
        textView.text = document.textDic
        // Store the text loaded from the document as the original text
        originalText = document.textDic
        navigationItem.title = document.title
        
        if let image = document.image {
            documentImageView.image = image
        } else {
            documentImageView.image = UIImage(systemName: "doc.text")
            documentImageView.tintColor = .systemGray3
        }
    }
}

// MARK: - UITextViewDelegate (To detect changes and enable Save button)
extension MyScanDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // Enable the Save button only if the new text is different from the original text
        saveButton.isEnabled = textView.text != originalText
    }
}


extension MyScanDetailViewController {
    private func showBannerAlert(message: String, duration: TimeInterval = 2.0) {
        
        let bannerView = UIView()
        bannerView.backgroundColor = Colors.grey4
        
        bannerView.layer.cornerRadius = 10
        bannerView.layer.masksToBounds = true
        
        let label = UILabel()
        label.text = message
        label.textColor = Colors.white
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        bannerView.addSubview(label)
        self.view.addSubview(bannerView)
        
        let padding: CGFloat = 16
        let height: CGFloat = 40
        
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -height),
            bannerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: padding),
            bannerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -padding),
            bannerView.heightAnchor.constraint(greaterThanOrEqualToConstant: height),

            label.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor, constant: padding),
            label.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: -padding),
        ])
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            bannerView.transform = CGAffineTransform(translationX: 0, y: self.view.safeAreaInsets.top + height + 10)
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                UIView.animate(withDuration: 0.5, animations: {
                    bannerView.transform = .identity
                }) { _ in
                    bannerView.removeFromSuperview()
                }
            }
        }
    }
}
