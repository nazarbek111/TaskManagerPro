//
//  OnboardingViewModel.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//

import Foundation
import Combine

final class OnboardingViewModel: ObservableObject {
    func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }
}
