//
//  OCRService.swift
//  i2tocr
//
//  Created by baner on 5/14/26.
//

import Foundation
import SwiftUI
import Vision

enum OCRError: LocalizedError {
    case imageConversionFailed
    case noTextFound
    case networkError(String)
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .imageConversionFailed: return "Image conversion failed"
        case .noTextFound: return "No text found in the image"
        case .networkError(let msg): return "Network error: \(msg)"
        case .serverError(let msg): return "Server error: \(msg)"
        }
    }
}

final class OCRService: OCRServiceProtocol {
    
    // MARK: - Vision OCR (Apple built-in)
    func extractTextVision(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.imageConversionFailed
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: OCRError.networkError(error.localizedDescription))
                    return
                }
                
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")
                
                if text.isEmpty {
                    continuation.resume(throwing: OCRError.noTextFound)
                } else {
                    continuation.resume(returning: text)
                }
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["fa", "en", "ar"]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: OCRError.networkError(error.localizedDescription))
            }
        }
    }
    
    func extractTextServer(from image: UIImage) async throws -> String {
        
        let url = URL(string: "https://i2tocr.onrender.com/ocr/sync")!
        let boundary = UUID().uuidString
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 90
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        
        var body = Data()
        
        func append(_ value: String) {
            body.append(Data(value.utf8))
        }
        
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"lang\"\r\n\r\n")
        append("fas\r\n")
        
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"config\"\r\n\r\n")
        append("--psm 6\r\n")
        
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n")
        append("Content-Type: image/jpeg\r\n\r\n")
        body.append(image.pngData()!)
        append("\r\n--\(boundary)--\r\n")
        
        request.httpBody = body
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder().decode(OCRResponse.self, from: responseData)
        
        guard result.status == "success", let text = result.data?.text else {
            throw NSError(
                domain: "OCR",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: result.detail ?? "OCR failed"]
            )
        }
        
        return text
    }
}
