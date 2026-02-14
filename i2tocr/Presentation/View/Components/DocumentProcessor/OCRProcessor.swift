//
//  OCRProcessor.swift
//  i2tocr-iOS
//
//  Created by baner on 11/30/25.
//  Copyright © 2025 i2tocr. All rights reserved.
//

import UIKit

/**
 Text recognition processor using i2tocr cloud-based OCR service.
 Provides high-accuracy text recognition for multiple languages.
 */
class OCRProcessor: BaseProcessor {
    
    // MARK: - Constants
    private let BASE_URL = "https://i2tocr.com"
    
    // MARK: - Public Methods
    
    /**
     Starts OCR processing by sending image to i2tocr server.
     
     - Parameters:
        - image: The image to process
        - language: Language code for OCR (e.g., "eng", "fas")
     */
    func startOCR(image: UIImage, language: String) {
        print("🌐 OCR Processor: Starting with language: \(language)")
        
        // Store the original image
        self.capturedImage = image
        
        // Convert to JPG before sending
        guard let imageData = ImageConverter.shared.convertToJPG(image, quality: 0.8) else {
            delegate?.processorDidFail(with: "Could not convert image to JPEG data.")
            return
        }
        
        sendImageForProcessing(imageData: imageData, language: language)
    }
    
    // MARK: - Private Methods
    
    private func sendImageForProcessing(imageData: Data, language: String) {
        guard let url = URL(string: BASE_URL + "/ocr") else {
            delegate?.processorDidFail(with: "Invalid API URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        // Add image file
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        data.append("\r\n".data(using: .utf8)!)
        
        // Add language parameter
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"lang\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(language)\r\n".data(using: .utf8)!)
        
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        URLSession.shared.uploadTask(with: request, from: data) { [weak self] responseData, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.processorDidFail(with: "Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let responseData = responseData else {
                DispatchQueue.main.async {
                    self.delegate?.processorDidFail(with: "Empty response from server")
                }
                return
            }
            
            // Check for HTTP errors
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                self.handleServerError(responseData: responseData, statusCode: httpResponse.statusCode)
                return
            }
            
            // Parse successful response
            self.parseSuccessResponse(data: responseData)
        }.resume()
    }
    
    private func handleServerError(responseData: Data, statusCode: Int) {
        let responseString = String(data: responseData, encoding: .utf8) ?? "N/A"
        
        do {
            if let errorJson = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let detail = errorJson["detail"] as? String {
                DispatchQueue.main.async {
                    self.delegate?.processorDidFail(with: "Server error \(statusCode): \(detail)")
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate?.processorDidFail(with: "Server returned error \(statusCode)")
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.delegate?.processorDidFail(with: "Server error \(statusCode). Response: \(responseString)")
            }
        }
    }
    
    private func parseSuccessResponse(data: Data) {
        do {
            let resultResponse = try JSONDecoder().decode(ServerResponse.self, from: data)
            let text = resultResponse.data.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            DispatchQueue.main.async {
                if text.isEmpty {
                    self.delegate?.processorDidFail(with: "OCR returned empty text")
                } else {
                    let cleanedText = self.cleanRecognizedText(text)
                    self.delegate?.processorDidFinish(with: cleanedText, image: self.capturedImage)
                }
            }
        } catch {
            let responseString = String(data: data, encoding: .utf8) ?? "N/A"
            DispatchQueue.main.async {
                self.delegate?.processorDidFail(with: "Invalid response format. Response: \(responseString)")
            }
        }
    }
}
