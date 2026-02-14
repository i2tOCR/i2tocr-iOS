//
//  ImageConverter.swift
//  i2tocr-iOS
//
//  Created by baner on 12/8/25.
//  Copyright © 2025 i2tocr. All rights reserved.
//

import UIKit

/**
 ImageConverter provides utility methods for converting, optimizing, and compressing images
 for OCR and Vision processing.
 */
class ImageConverter {
    
    // MARK: - Singleton
    static let shared = ImageConverter()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /**
     Converts a UIImage to JPG format data WITHOUT resizing.
     
     - Parameters:
        - image: The source UIImage to convert
        - quality: Compression quality from 0.0 to 1.0 (default: 0.8)
     - Returns: JPG data if conversion succeeds, nil otherwise
     */
    func convertToJPG(_ image: UIImage, quality: CGFloat = 0.8) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }
    
    /**
     Converts a UIImage to JPG format and returns a new UIImage WITHOUT resizing.
     
     - Parameters:
        - image: The source UIImage to convert
        - quality: Compression quality from 0.0 to 1.0 (default: 0.8)
     - Returns: Converted UIImage in JPG format, nil if conversion fails
     */
    func convertToJPGImage(_ image: UIImage, quality: CGFloat = 0.8) -> UIImage? {
        guard let jpgData = convertToJPG(image, quality: quality) else {
            return nil
        }
        return UIImage(data: jpgData)
    }
    
    /**
     Converts image to JPG and improves contrast WITHOUT resizing.
     
     - Parameter image: The source UIImage to optimize
     - Returns: Optimized UIImage for OCR, nil if optimization fails
     */
    func optimizeForOCR(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else {
            return convertToJPGImage(image)
        }
        
        let context = CIContext(options: nil)
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let filter = CIFilter(name: "CIColorControls") else {
            return convertToJPGImage(image) // Fallback
        }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(1.2, forKey: kCIInputContrastKey)
        filter.setValue(0.1, forKey: kCIInputBrightnessKey)
        
        guard let outputImage = filter.outputImage,
              let cgImageOutput = context.createCGImage(outputImage, from: outputImage.extent) else {
            return convertToJPGImage(image) // Fallback
        }
        
        return UIImage(cgImage: cgImageOutput)
    }
    
    /**
     Preprocesses an image for Apple Vision framework WITHOUT resizing.
     
     - Parameter image: The source UIImage to preprocess
     - Returns: Preprocessed UIImage for Vision, nil if preprocessing fails
     */
    func preprocessForVision(_ image: UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage else {
            return convertToJPGImage(image) // Fallback
        }
        
        let context = CIContext(options: nil)
        let ciImage = CIImage(cgImage: cgImage)
        
        guard let sharpenFilter = CIFilter(name: "CISharpenLuminance") else {
            return convertToJPGImage(image) // Fallback
        }
        
        sharpenFilter.setValue(ciImage, forKey: kCIInputImageKey)
        sharpenFilter.setValue(0.5, forKey: kCIInputSharpnessKey)
        
        guard let sharpenedImage = sharpenFilter.outputImage else {
            return convertToJPGImage(image) // Fallback
        }
        
        guard let contrastFilter = CIFilter(name: "CIColorControls") else {
            return convertToJPGImage(image) // Fallback
        }
        
        contrastFilter.setValue(sharpenedImage, forKey: kCIInputImageKey)
        contrastFilter.setValue(1.1, forKey: kCIInputContrastKey)
        
        guard let outputImage = contrastFilter.outputImage,
              let cgImageOutput = context.createCGImage(outputImage, from: outputImage.extent) else {
            return convertToJPGImage(image) // Fallback
        }
        
        return UIImage(cgImage: cgImageOutput)
    }
    
    // MARK: - Simple Conversion
    
    /**
     Simply converts image to JPG format without any processing.
     
     - Parameters:
        - image: The source UIImage
        - quality: Compression quality (default: 0.8)
     - Returns: JPG UIImage
     */
    func simpleConvertToJPG(_ image: UIImage, quality: CGFloat = 0.8) -> UIImage? {
        return convertToJPGImage(image, quality: quality)
    }
    
    /**
     Converts image to JPG data without any processing.
     
     - Parameters:
        - image: The source UIImage
        - quality: Compression quality (default: 0.8)
     - Returns: JPG Data
     */
    func simpleConvertToJPGData(_ image: UIImage, quality: CGFloat = 0.8) -> Data? {
        return convertToJPG(image, quality: quality)
    }
    
    // MARK: - Compression Methods
    
    /**
     Compresses an image to a target maximum size in kilobytes.
     
     - Parameters:
        - image: The source UIImage to compress
        - maxSizeInKB: Maximum file size in kilobytes (default: 500 KB)
     - Returns: Compressed image data, nil if compression fails
     */
    func compressImage(_ image: UIImage, maxSizeInKB: Int = 500) -> Data? {
        var compression: CGFloat = 1.0
        guard var imageData = image.jpegData(compressionQuality: compression) else {
            return nil
        }
        
        let maxSize = maxSizeInKB * 1024
        
        // Reduce quality until target size is reached
        while imageData.count > maxSize && compression > 0.1 {
            compression -= 0.1
            if let newData = image.jpegData(compressionQuality: compression) {
                imageData = newData
            } else {
                break
            }
        }
        
        return imageData
    }
    
    // MARK: - Utility Methods
    
    /**
     Gets detailed information about an image.
     
     - Parameter image: The UIImage to analyze
     - Returns: Tuple containing size, scale, and orientation
     */
    func getImageInfo(_ image: UIImage) -> (size: CGSize, scale: CGFloat, orientation: UIImage.Orientation) {
        return (image.size, image.scale, image.imageOrientation)
    }
    
    /**
     Prints image information for debugging.
     
     - Parameter image: The UIImage to analyze
     */
    func printImageInfo(_ image: UIImage, label: String = "Image") {
        let info = getImageInfo(image)
        print("📊 \(label) Info:")
        print("   Size: \(Int(info.size.width))x\(Int(info.size.height))")
        print("   Scale: \(info.scale)")
        print("   Orientation: \(info.orientation.rawValue)")
        
        if let data = image.jpegData(compressionQuality: 1.0) {
            print("   File Size: \(data.count / 1024) KB")
        }
    }
}
