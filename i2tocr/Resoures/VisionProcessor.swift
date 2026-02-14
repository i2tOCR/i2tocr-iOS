//
//  VisionProcessor.swift
//  i2tocr-iOS
//
//  Created by baner on 12/8/25.
//  Copyright © 2025 i2tocr. All rights reserved.
//

import UIKit
import Vision

/**
 Text recognition processor using Apple's Vision framework.
 Provides on-device text recognition without requiring internet connection.
 */
class VisionProcessor: BaseProcessor {
    
    // MARK: - Public Methods
    
    /**
     Processes an image using Apple Vision framework for text recognition.
     
     - Parameters:
        - image: The image to process
        - language: Language code for text recognition (default: "eng")
     */
    override func processImage(_ image: UIImage, language: String = "eng") {
        print("🔍 Vision Processor: Starting image processing...")
        
        // Store the original image
        self.capturedImage = image
        
        guard let processedImage = ImageConverter.shared.preprocessForVision(image) else {
            delegate?.processorDidFail(with: "Failed to preprocess image for Vision")
            return
        }
        
        guard let cgImage = processedImage.cgImage else {
            delegate?.processorDidFail(with: "Cannot convert image to CGImage")
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            DispatchQueue.main.async {
                self?.handleTextRecognition(request: request, error: error)
            }
        }
        
        // Configure Vision request
        request.recognitionLanguages = getVisionLanguageCodes(for: language)
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.01
        request.customWords = []
        
        print("🔍 Vision Processor: Language set to \(language)")
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                print("🔍 Vision Processor: Performing text recognition...")
                try handler.perform([request])
            } catch {
                print("❌ Vision Processor Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.delegate?.processorDidFail(with: "Vision processing failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handleTextRecognition(request: VNRequest, error: Error?) {
        print("🔍 Vision Processor: Handling recognition result...")
        
        if let error = error {
            print("❌ Vision Recognition Error: \(error.localizedDescription)")
            delegate?.processorDidFail(with: "Vision error: \(error.localizedDescription)")
            return
        }
        
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            print("⚠️ Vision Processor: No text observations found")
            delegate?.processorDidFail(with: "No text found in image")
            return
        }
        
        print("🔍 Vision Processor: Found \(observations.count) text observations")
        
        // Sort observations from top to bottom
        let sortedObservations = observations.sorted {
            $0.boundingBox.minY > $1.boundingBox.minY
        }
        
        var recognizedText = ""
        for (index, observation) in sortedObservations.enumerated() {
            if let candidate = observation.topCandidates(1).first {
                let text = candidate.string
                let confidence = candidate.confidence
                
                // Include text with confidence above threshold
                if confidence > 0.1 {
                    recognizedText += text
                    if index < sortedObservations.count - 1 {
                        recognizedText += "\n"
                    }
                    print("🔍 Found text: '\(text)' with confidence: \(confidence)")
                }
            }
        }
        
        if recognizedText.isEmpty {
            print("⚠️ Vision Processor: No readable text found")
            delegate?.processorDidFail(with: "No readable text found. Try a clearer image.")
        } else {
            print("✅ Vision Processor Success: Text recognized (\(recognizedText.count) characters)")
            let cleanedText = cleanRecognizedText(recognizedText)
            delegate?.processorDidFinish(with: cleanedText, image: capturedImage)
        }
    }
}
