//
//  GetCurrentEngineUseCase.swift
//  i2tocr
//
//  Created by baner on 1/4/26.
//

import UIKit
import RxSwift

// MARK: - Engine UseCases
final class GetCurrentEngineUseCase {
    func execute() -> ProcessingEngine {
        UserDefaults.standard.processingEngine
    }
}
