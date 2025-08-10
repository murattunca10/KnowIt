//
//  DifficultyVM.swift
//  KnowIt
//
//  Created by Murat Tunca on 10.08.2025.
//

import Foundation

class DifficultyVM {
    
    private(set) var selectedDifficulty: String? {
        didSet {
            onDifficultyChanged?(selectedDifficulty)
        }
    }
    
    var onDifficultyChanged: ((String?) -> Void)?
    
    func selectDifficulty(_ level: String) {
        selectedDifficulty = level.lowercased()
    }
    
    func resetDifficulty() {
        selectedDifficulty = nil
    }

}
