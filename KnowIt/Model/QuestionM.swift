//
//  QuestionM.swift
//  KnowIt
//
//  Created by Murat Tunca on 9.08.2025.
//

struct QuestionM: Codable {
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    
    var allAnswers: [String] {
        (incorrect_answers + [correct_answer]).shuffled()
    }
}
