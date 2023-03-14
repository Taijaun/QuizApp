//
//  Question.swift
//  QuizApp
//
//  Created by Taijaun Pitt on 05/03/2023.
//

import Foundation

struct Question: Codable {
    
    var question: String?
    var answers: [String]?
    var correctAnswerIndex: Int?
    var feedback: String?
    
}
