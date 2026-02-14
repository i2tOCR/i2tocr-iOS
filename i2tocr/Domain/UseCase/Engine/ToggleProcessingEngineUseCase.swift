//
//  ToggleProcessingEngineUseCase.swift
//  i2tocr
//
//  Created by baner on 1/4/26.
//

import UIKit
import RxSwift

final class ToggleProcessingEngineUseCase {
    func execute(current: ProcessingEngine) -> ProcessingEngine {
        let next: ProcessingEngine =
            current == .ocr ? .vision : .ocr
        UserDefaults.standard.processingEngine = next
        NotificationCenter.default.post(
            name: NSNotification.Name("ProcessingEngineChanged"),
            object: next
        )
        return next
    }
}
