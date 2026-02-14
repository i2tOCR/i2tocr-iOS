//
//  BaseProcessorDelegate.swift
//  i2tocr-iOS
//
//  Created by baner on 12/8/25.
//  Copyright © 2025 i2tocr. All rights reserved.
//

import UIKit

/**
 Delegate protocol for receiving processing results from text recognition engines.
 */
protocol BaseProcessorDelegate: AnyObject {
    
    /**
     Called when text recognition completes successfully.
     
     - Parameters:
        - text: The recognized text
        - image: The image that was processed (may be optimized version)
     */
    func processorDidFinish(with text: String, image: UIImage?)
    
    /**
     Called when text recognition fails.
     
     - Parameter error: Error description
     */
    func processorDidFail(with error: String)
}


//
//  BaseProcessor.swift
//  i2tocr-iOS
//
//  Created by baner on 12/8/25.
//  Copyright © 2025 i2tocr. All rights reserved.
//

import UIKit

/**
 Abstract base class for text processing engines.
 Provides common functionality and properties.
 */
class BaseProcessor {
    
    // MARK: - Properties
    
    /// Delegate to receive processing results
    weak var delegate: BaseProcessorDelegate?
    
    /// The image captured during processing
    var capturedImage: UIImage?
    
    /// Unique identifier for tracking processing requests
    var processingId: String?
    
    // MARK: - Shared Methods
    
    /**
     Processes an image for text recognition.
     
     - Parameters:
        - image: The image to process
        - language: Language code for text recognition
     */
    func processImage(_ image: UIImage, language: String = "eng") {
        guard let processedImage = ImageConverter.shared.optimizeForOCR(image) else {
            delegate?.processorDidFail(with: "Failed to process image")
            return
        }
        
        capturedImage = processedImage
    }
    
    // MARK: - Language Support
    
    /**
     Converts generic language codes to Vision framework language codes.
     
     - Parameter langCode: Generic language code (e.g., "eng", "fas")
     - Returns: Array of Vision language codes
     */
    func getVisionLanguageCodes(for langCode: String) -> [String] {
        switch langCode.lowercased() {
        case "eng", "en": return ["en-US"]
        case "fas", "fa": return ["fa-IR", "en-US"] // Farsi with English fallback
        case "fra", "fr": return ["fr-FR", "en-US"]
        case "deu", "de": return ["de-DE", "en-US"]
        case "jpn", "ja": return ["ja-JP", "en-US"]
        default: return ["en-US"] // Default to English
        }
    }
    
    /**
     Gets list of supported languages for text recognition.
     
     - Returns: Array of tuples containing language name and code
     */
    func getSupportedLanguages() -> [(name: String, code: String)] {
        return [
            ("English", "eng"),
            ("Farsi (Persian)", "fas"),
            ("French", "fra"),
            ("German", "deu"),
            ("Japanese", "jpn")
        ]
    }
    
    // MARK: - Text Processing Utilities
    
    /**
     Cleans recognized text by removing empty lines and trimming whitespace.
     
     - Parameter text: Raw recognized text
     - Returns: Cleaned text
     */
    func cleanRecognizedText(_ text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let lines = cleaned.components(separatedBy: .newlines)
        let validLines = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.count > 1
        }
        
        cleaned = validLines.joined(separator: "\n")
        return cleaned
    }
}
