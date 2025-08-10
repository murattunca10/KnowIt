//
//  Untitled.swift
//  KnowIt
//
//  Created by Murat Tunca on 9.08.2025.
//

import UIKit

class QuizVC: UIViewController {
    
    private let viewModel: QuizVM
    
    init(viewModel: QuizVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let questionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 20, weight: .semibold)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
    }()
    
    private var answerButtons: [UIButton] = []
    
    private let nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.isHidden = true
        return btn
    }()
    
    private let scoreLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16)
        lbl.textAlignment = .center
        lbl.text = "Score: 0"
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bindViewModel()
        viewModel.loadQuestions(type: "multiple")
        navigationItem.title = "Quiz"
    }
    
    private func setupUI() {
        view.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        view.addSubview(questionLabel)
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        for _ in 0..<4 {
            let btn = UIButton(type: .system)
            btn.titleLabel?.font = .systemFont(ofSize: 18)
            btn.setTitleColor(.systemBlue, for: .normal)
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.systemBlue.cgColor
            btn.layer.cornerRadius = 8
            btn.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
            btn.translatesAutoresizingMaskIntoConstraints = false
            answerButtons.append(btn)
            view.addSubview(btn)
        }
        
        // Buton layout
        let spacing: CGFloat = 16
        for i in 0..<answerButtons.count {
            NSLayoutConstraint.activate([
                answerButtons[i].leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                answerButtons[i].trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                answerButtons[i].heightAnchor.constraint(equalToConstant: 44)
            ])
            
            if i == 0 {
                answerButtons[i].topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 30).isActive = true
            } else {
                answerButtons[i].topAnchor.constraint(equalTo: answerButtons[i-1].bottomAnchor, constant: spacing).isActive = true
            }
        }
        
        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: answerButtons.last!.bottomAnchor, constant: 30),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.onQuestionsLoaded = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.onAnswerChecked = { [weak self] isCorrect, correctAnswer in
            let alert = UIAlertController(
                title: isCorrect ? "Correct!" : "Wrong!",
                message: isCorrect ? "Good job!" : "Correct answer: \(correctAnswer.htmlDecoded)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
            
            self?.scoreLabel.text = "Score: \(self?.viewModel.score ?? 0)"
            self?.nextButton.isHidden = false
            self?.setButtonsEnabled(false)
        }
        
        viewModel.onQuizFinished = { [weak self] in
            let alert = UIAlertController(
                title: "Quiz Finished",
                message: "Your final score is \(self?.viewModel.score ?? 0)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Restart", style: .default) { _ in
                self?.viewModel.loadQuestions(type: "multiple")
            })
            self?.present(alert, animated: true)
        }
        
        viewModel.onError = { error in
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func updateUI() {
        guard let question = viewModel.currentQuestion else {
            questionLabel.text = "No question"
            answerButtons.forEach { $0.isHidden = true }
            nextButton.isHidden = true
            return
        }

        questionLabel.text = question.question.htmlDecoded
        let answers = question.allAnswers

        for (i, btn) in answerButtons.enumerated() {
            btn.isHidden = false
            btn.setTitle(answers[i].htmlDecoded, for: .normal)
            btn.backgroundColor = .clear
            btn.isEnabled = true
        }
        
        nextButton.isHidden = true
        scoreLabel.text = "Score: \(viewModel.score)"
    }
    
    private func setButtonsEnabled(_ enabled: Bool) {
        answerButtons.forEach { $0.isEnabled = enabled }
    }
    
    @objc private func answerTapped(_ sender: UIButton) {
        guard let answer = sender.title(for: .normal) else { return }
        viewModel.checkAnswer(answer)
    }
    
    @objc private func nextTapped() {
        viewModel.nextQuestion()
    }
}
