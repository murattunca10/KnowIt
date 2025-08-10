//
//  QuizManager.swift
//  KnowIt
//
//  Created by Murat Tunca on 9.08.2025.
//

import Foundation

class QuestionManager {
    static let shared = QuestionManager()
    private init() {}
    
    func getQuestions(amount: Int, category: Int, difficulty: String, type: String, completion: @escaping (Result<[QuestionM], Error>) -> Void) {
        let url = "\(NetworkHelper.shared.baseURL)/api.php?amount=\(amount)&category=\(category)&difficulty=\(difficulty)&type=\(type)"
        
        NetworkManager.shared.request(type: TriviaR.self, url: url, method: "GET") { result in
            switch result {
            case .success(let triviaResponse):
                completion(.success(triviaResponse.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
