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
    
    private let stack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupButtons()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.resetDifficulty()
        updateButtonSelection(nil)
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
    }
    
    private func setupView() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemIndigo.cgColor,
            UIColor.systemPurple.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupButtons() {
        let buttons = [easyButton, mediumButton, hardButton]
        let titles = ["Easy", "Medium", "Hard"]
        
        for (index, button) in buttons.enumerated() {
            button.setTitle(titles[index], for: .normal)
            button.backgroundColor = .white
            button.layer.cornerRadius = 20
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            button.setTitleColor(.systemIndigo, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.15
            button.layer.shadowOffset = CGSize(width: 0, height: 6)
            button.layer.shadowRadius = 8
            
            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchDragExit, .touchCancel])
            button.addTarget(self, action: #selector(difficultyButtonTapped(_:)), for: .touchUpInside)
        }
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.backgroundColor = .systemGreen
        nextButton.layer.cornerRadius = 25
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        stack.axis = .vertical
        stack.spacing = 25
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        buttons.forEach { stack.addArrangedSubview($0) }
        stack.addArrangedSubview(nextButton)
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            easyButton.heightAnchor.constraint(equalToConstant: 60),
            mediumButton.heightAnchor.constraint(equalToConstant: 60),
            hardButton.heightAnchor.constraint(equalToConstant: 60),
            nextButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupBindings() {
        viewModel.onDifficultyChanged = { [weak self] difficulty in
            self?.updateButtonSelection(difficulty)
            let enabled = (difficulty != nil && difficulty != "")
            self?.nextButton.isEnabled = enabled
            UIView.animate(withDuration: 0.25) {
                self?.nextButton.alpha = enabled ? 1 : 0.5
            }
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
            "Easy": easyButton,
            "Medium": mediumButton,
            "Hard": hardButton
        ]
        
        for (level, button) in buttons {
            let isSelected = (level == selected)
            button.backgroundColor = isSelected ? .systemCyan : .white
            button.setTitleColor(isSelected ? .white : .systemIndigo, for: .normal)
            button.layer.shadowOpacity = isSelected ? 0.4 : 0.15
            button.transform = isSelected ? CGAffineTransform(scaleX: 1.05, y: 1.05) : .identity
        }
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15) {
            sender.transform = .identity
        }
    }
}
