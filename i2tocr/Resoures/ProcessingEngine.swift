//
//  ProcessingEngine.swift
//  i2tocr-iOS
//
//  Created by baner on 12/8/25.
//  Copyright © 2025 i2tocr. All rights reserved.
//

import Foundation

/**
 Enum representing available text processing engines.
 */
enum ProcessingEngine: String, CaseIterable {
    case ocr = "ocr"
    case vision = "vision"
    
    /// Display name for UI presentation
    var displayName: String {
        switch self {
        case .ocr: return "OCR"
        case .vision: return "Apple Vision"
        }
    }
    
    /// SF Symbol icon name for UI presentation
    var iconName: String {
        switch self {
        case .ocr: return "network"
        case .vision: return "eye"
        }
    }
    
    /// Detailed description of the engine
    var description: String {
        switch self {
        case .ocr: return "Cloud-based OCR processing using i2tocr server"
        case .vision: return "On-device text recognition using Apple Vision framework"
        }
    }
}

// MARK: - UserDefaults Extension
extension UserDefaults {
    private enum Keys {
        static let processingEngine = "processingEngine"
    }
    
    /**
     Gets or sets the current processing engine preference.
     Defaults to OCR if no preference is saved.
     */
    var processingEngine: ProcessingEngine {
        get {
            if let savedEngine = string(forKey: Keys.processingEngine),
               let engine = ProcessingEngine(rawValue: savedEngine) {
                return engine
            }
            return .ocr // Default engine
        }
        set {
            set(newValue.rawValue, forKey: Keys.processingEngine)
        }
    }
}
