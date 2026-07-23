//
//  SplashViewModel.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 23/07/26.
//

import Foundation

@MainActor
protocol SplashViewModelType {
    func loadFeatureFlags() async throws
}

@MainActor
class SplashViewModel: SplashViewModelType {
    private let featureFlagsService: FeatureFlagsServiceType
    
    init(featureFlagsService: FeatureFlagsServiceType) {
        self.featureFlagsService = featureFlagsService
    }
    
    func loadFeatureFlags() async throws {
        await featureFlagsService.start()
    }
}
