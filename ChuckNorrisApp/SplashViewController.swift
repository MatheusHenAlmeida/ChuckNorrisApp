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

    var viewModel: SplashViewModelType?

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("something_went_wrong_try_again_later", comment: "Error message for remote config connection failure")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRemoteConfigAndProceed()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.929, green: 0.557, blue: 0.310, alpha: 1.0)
        
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
    }

    private func loadRemoteConfigAndProceed() {
        Task { [weak self] in
            do {
                try await self?.viewModel?.loadFeatureFlags()
                self?.navigateToMainScreen()
            } catch {
                self?.activityIndicator.isHidden = true
                self?.errorLabel.isHidden = false
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

