//
//  QuizVM.swift
//  KnowIt
//
//  Created by Murat Tunca on 9.08.2025.
//

import Foundation

class QuizVM {
   
    private(set) var difficulty: String
    private var questions: [QuestionM] = []
    private(set) var currentIndex: Int = 0
    private(set) var score: Int = 0
    
    var onQuestionsLoaded: (() -> Void)?
    var onAnswerChecked: ((Bool, String) -> Void)?
    var onQuizFinished: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(difficulty: String) {
        self.difficulty = difficulty
    }
    
    var currentQuestion: QuestionM? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var totalQuestions: Int {
        questions.count
    }

    func loadQuestions(amount: Int = 3, category: Int = 0, type: String, completion: (() -> Void)? = nil) {
        QuestionManager.shared.getQuestions(amount: amount, category: category, difficulty: difficulty, type: type) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let questions):
                    self?.questions = questions
                    self?.currentIndex = 0
                    self?.score = 0
                    self?.onQuestionsLoaded?()
                    completion?()
                case .failure(let error):
                    self?.onError?(error)
                    print("Error:", error.localizedDescription)
                }
            }
        }
    }
    
    func checkAnswer(_ answer: String) {
        guard let question = currentQuestion else { return }
        let correct = (answer == question.correct_answer)
        if correct {
            score += 1
        }
        onAnswerChecked?(correct, question.correct_answer)
    }
    
    func nextQuestion() {
        currentIndex += 1
        if currentIndex >= questions.count {
            onQuizFinished?()
        } else {
            onQuestionsLoaded?()
        }
    }
}
