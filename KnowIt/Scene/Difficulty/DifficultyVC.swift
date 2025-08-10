//
//  DifficultyVC.swift
//  KnowIt
//
//  Created by Murat Tunca on 10.08.2025.
//

import UIKit

class DifficultyVC: UIViewController {
    
    private let viewModel = DifficultyVM()
    
    private let easyButton = UIButton(type: .system)
    private let mediumButton = UIButton(type: .system)
    private let hardButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupButtons()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.resetDifficulty()
        nextButton.isHidden = true
    }
    
    private func setupButtons() {
        let buttons = [easyButton, mediumButton, hardButton]
        let titles = ["Easy", "Medium", "Hard"]
        
        for (index, button) in buttons.enumerated() {
            button.setTitle(titles[index], for: .normal)
            button.backgroundColor = .systemGray5
            button.layer.cornerRadius = 8
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            button.addTarget(self, action: #selector(difficultyButtonTapped(_:)), for: .touchUpInside)
        }
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.backgroundColor = .systemGreen
        nextButton.layer.cornerRadius = 8
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: buttons + [nextButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: 200),
            easyButton.heightAnchor.constraint(equalToConstant: 44),
            mediumButton.heightAnchor.constraint(equalToConstant: 44),
            hardButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupBindings() {
        viewModel.onDifficultyChanged = { [weak self] difficulty in
            self?.updateButtonSelection(difficulty)
            self?.nextButton.isHidden = (difficulty == nil || difficulty == "")
        }
    }
    
    @objc private func difficultyButtonTapped(_ sender: UIButton) {
        if sender == easyButton {
            viewModel.selectDifficulty("Easy")
        } else if sender == mediumButton {
            viewModel.selectDifficulty("Medium")
        } else if sender == hardButton {
            viewModel.selectDifficulty("Hard")
        }
    }
    
    @objc private func nextTapped() {
        let quizVM = QuizVM(difficulty: viewModel.selectedDifficulty ?? "")
        let quizVC = QuizVC(viewModel: quizVM)
        navigationController?.pushViewController(quizVC, animated: true)
    }
    
    private func updateButtonSelection(_ selected: String?) {
        let buttons: [String: UIButton] = [
            "easy": easyButton,
            "medium": mediumButton,
            "hard": hardButton
        ]
        
        for (level, button) in buttons {
            let isSelected = (level == selected)
            button.backgroundColor = isSelected ? .systemBlue : .systemGray5
            button.setTitleColor(isSelected ? .white : .black, for: .normal)
        }
    }

}
