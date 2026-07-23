//
//  SplashViewController.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 23/07/26.
//

import UIKit
import Swinject
import SwinjectStoryboard
import FirebaseRemoteConfigInternal

class SplashViewController: UIViewController {

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRemoteConfigAndProceed()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.929, green: 0.557, blue: 0.310, alpha: 1.0)
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
    }

    private func loadRemoteConfigAndProceed() {
        Task { [weak self] in
            let remoteConfig = RemoteConfig.remoteConfig()
            let featureFlagsService = FeatureFlagsService(remoteConfig: remoteConfig)
            
            do {
                try await featureFlagsService.start()
                guard let weakSelf = self else { return }
                weakSelf.navigateToMainScreen()
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

