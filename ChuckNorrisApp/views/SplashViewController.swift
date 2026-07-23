//
//  SplashViewController.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 23/07/26.
//

import UIKit
import Swinject
import SwinjectStoryboard

class SplashViewController: UIViewController {

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Chuck Norris App"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRemoteConfigAndProceed()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.929, green: 0.557, blue: 0.310, alpha: 1.0)
        
        view.addSubview(titleLabel)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
        ])
        
        activityIndicator.startAnimating()
    }

    private func loadRemoteConfigAndProceed() {
        let container = SwinjectStoryboard.defaultContainer
        let featureFlagsService = container.resolve(FeatureFlagsServiceType.self)
        
        Task {
            // Executa a busca assíncrona do Remote Config
            await featureFlagsService?.start()
            
            // Garante que a transição de tela aconteça na Main Thread
            await MainActor.run {
                self.navigateToMainScreen()
            }
        }
    }

    private func navigateToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
        mainViewController.modalPresentationStyle = .fullScreen
        mainViewController.modalTransitionStyle = .crossDissolve
        present(mainViewController, animated: true)
    }
}
