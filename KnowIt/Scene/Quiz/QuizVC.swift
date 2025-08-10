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
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        progress.progressTintColor = UIColor.systemGreen
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private let questionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 24, weight: .bold)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.textColor = .white
        return lbl
    }()
    
    private var answerButtons: [UIButton] = []
    
    private let nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 20)
        btn.backgroundColor = UIColor.systemGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 25
        btn.isHidden = true
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.25
        btn.layer.shadowOffset = CGSize(width: 0, height: 5)
        btn.layer.shadowRadius = 8
        return btn
    }()
    
    private let scoreLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 18, weight: .medium)
        lbl.textAlignment = .center
        lbl.textColor = UIColor.white.withAlphaComponent(0.9)
        lbl.text = "Score: 0"
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupUI()
        bindViewModel()
        viewModel.loadQuestions(type: "multiple")
        navigationItem.title = "Quiz"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemPurple.cgColor,
            UIColor.systemIndigo.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupUI() {
        view.addSubview(scoreLabel)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(questionLabel)
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        for _ in 0..<4 {
            let btn = UIButton(type: .system)
            btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.8)
            btn.layer.cornerRadius = 15
            btn.layer.shadowColor = UIColor.black.cgColor
            btn.layer.shadowOpacity = 0.3
            btn.layer.shadowOffset = CGSize(width: 0, height: 6)
            btn.layer.shadowRadius = 8
            
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
            
            answerButtons.append(btn)
            view.addSubview(btn)
        }
        
        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            questionLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            progressView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            progressView.heightAnchor.constraint(equalToConstant: 6),
            
            questionLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
        
        let spacing: CGFloat = 20
        
        for i in 0..<answerButtons.count {
            let btn = answerButtons[i]
            NSLayoutConstraint.activate([
                btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                btn.heightAnchor.constraint(equalToConstant: 54)
            ])
            
            if i == 0 {
                btn.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 30).isActive = true
            } else {
                btn.topAnchor.constraint(equalTo: answerButtons[i - 1].bottomAnchor, constant: spacing).isActive = true
            }
        }
        
        NSLayoutConstraint.activate([
            nextButton.topAnchor.constraint(equalTo: answerButtons.last!.bottomAnchor, constant: 40),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 140),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onQuestionsLoaded = { [weak self] in
            self?.updateUI()
        }
        
        viewModel.onAnswerChecked = { [weak self] isCorrect, correctAnswer in
            guard let self = self else { return }
            
            self.highlightAnswerButtons(selectedAnswerCorrect: isCorrect, correctAnswer: correctAnswer)
            self.scoreLabel.text = "Score: \(self.viewModel.score)"
            self.nextButton.isHidden = false
            self.setButtonsEnabled(false)
        }
        
        viewModel.onQuizFinished = { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(
                title: "Quiz Finished",
                message: "Your final score is \(self.viewModel.score)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Restart", style: .default) { _ in
                self.viewModel.loadQuestions(type: "multiple")
            })
            self.present(alert, animated: true)
        }
        
        viewModel.onError = { error in
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func highlightAnswerButtons(selectedAnswerCorrect: Bool, correctAnswer: String) {
        for btn in answerButtons {
            guard let title = btn.title(for: .normal) else { continue }
            if title == correctAnswer.htmlDecoded {
                // Doğru cevap yeşil
                btn.backgroundColor = .systemGreen
                btn.setTitleColor(.white, for: .normal)
                btn.layer.shadowColor = UIColor.systemGreen.cgColor
                btn.layer.shadowOpacity = 0.6
            } else {
                // Diğerleri kırmızı veya koyu gri (yanlış)
                btn.backgroundColor = selectedAnswerCorrect ? UIColor.systemIndigo.withAlphaComponent(0.7) : UIColor.systemRed.withAlphaComponent(0.7)
                btn.setTitleColor(.white, for: .normal)
                btn.layer.shadowColor = UIColor.black.cgColor
                btn.layer.shadowOpacity = 0.3
            }
        }
    }
    
    private func updateUI() {
        guard let question = viewModel.currentQuestion else {
            questionLabel.text = "No question"
            answerButtons.forEach { $0.isHidden = true }
            nextButton.isHidden = true
            progressView.progress = 0
            return
        }
        
        questionLabel.text = question.question.htmlDecoded
        let answers = question.allAnswers
        
        for (i, btn) in answerButtons.enumerated() {
            btn.isHidden = false
            btn.setTitle(answers[i].htmlDecoded, for: .normal)
            btn.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.8)
            btn.setTitleColor(.white, for: .normal)
            btn.layer.shadowColor = UIColor.black.cgColor
            btn.layer.shadowOpacity = 0.3
            btn.isEnabled = true
        }
        
        nextButton.isHidden = true
        scoreLabel.text = "Score: \(viewModel.score)"
        
        let progress = Float(viewModel.currentIndex) / Float(viewModel.totalQuestions)
        progressView.setProgress(progress, animated: true)
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
